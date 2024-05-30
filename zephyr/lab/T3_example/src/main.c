/*
 * Copyright (c) 2022 Libre Solar Technologies GmbH
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/drivers/kscan.h>
#include <zephyr/drivers/uart.h>

#include <string.h>

#define RECEIVE_TIMEOUT 1000

#define MSG_SIZE 9
#define CO2_MULTIPLIER 256

//K_MSGQ_DEFINE(uart_msgq, MSG_SIZE, 10, 4);

static const struct device *const uart_serial = DEVICE_DT_GET(DT_N_ALIAS_myserial);

/* receive buffer used in UART ISR callback */
static char rx_buf[MSG_SIZE];
static int rx_buf_pos=0;

enum uart_fsm_state_code {
	UART_FSM_IDLE,
	UART_FSM_HEADER,
	UART_FSM_DATA,
	UART_FSM_CHECKSUM,
	UART_FSM_END,
};

static uint8_t uart_fsm_state = UART_FSM_IDLE; // initial state

/**
 * Finite State Machine of the reading of the UART communication protocol
 * IDLE -> start reading HEADER -> read DATA -> validity of CHECKSUM -> END
 * 
 * @param reset Optional to initiate reset
 * @param read_data Data for transitions of the (global) FSM
 * 
 * @returns Updated current FSM state
*/
uint8_t check_uart_fsm(uint8_t reset, uint8_t read_data) {
	if(reset)
	   uart_fsm_state = UART_FSM_IDLE;
	else 
	    switch (uart_fsm_state) {
        case UART_FSM_IDLE:
          if (read_data == 0xFF) { // start checking
            uart_fsm_state = UART_FSM_HEADER;
          }
          break;
        case UART_FSM_HEADER:
          if (read_data == 0x86) { // valid header
            uart_fsm_state = UART_FSM_DATA;
          } else {
            uart_fsm_state = UART_FSM_IDLE;
          }
          break;
        case UART_FSM_DATA:
          if (rx_buf_pos == MSG_SIZE - 2) { // until checksum
            uart_fsm_state = UART_FSM_CHECKSUM;
          }
          break;
        case UART_FSM_CHECKSUM:
          if (rx_buf_pos == MSG_SIZE - 1) { // end
            uart_fsm_state = UART_FSM_END;
          }
          break;
        case UART_FSM_END:
          uart_fsm_state = UART_FSM_IDLE;
          break;
        default:
          uart_fsm_state = UART_FSM_IDLE;
          break;
      }
	return uart_fsm_state;
}

struct k_work uart_work_que;
struct k_timer uart_timer;


void uart_work_handler () {
  serial_write();
}

/**
 * Enqueues k_work to K_WORK queue
 * 
 * @param timer_id ID of the callback callee
*/
void uart_expiry_function (struct k_timer *timer_id) {
  if (k_work_submit(&uart_work_que) < 0) {
    printk("Error: work not submitted to queue\n");
    return;
  }
}

/**
 * Gets check sum value from given packet
 * 
 * @param packet Received packet
 * @returns Sum of bits 1 to 8
*/
unsigned char getCheckSum(char *packet) {
	unsigned char i, checksum=0;
	for(i = 1; i < 8; i++) {
		checksum += packet[i];
	}
	checksum = 0xff - checksum;
	checksum += 1;
	return checksum;
}

/**
 * Read data via UART IRQ.
 *
 * @param dev UART device struct
 * @param user_data Pointer to user data (NULL in this practice)
 */
void serial_callback(const struct device *dev, void *user_data) {
	uint8_t c;

	if (!uart_irq_update(uart_serial)) {
		printk("irq_update Error\n");
		return;
	}

	if (!uart_irq_rx_ready(uart_serial)) {
		printk("irq_ready: No data\n");
		return;
	}

	/* read until FIFO empty */
	while (uart_fifo_read(uart_serial, &c, 1) == 1) {
		// for recovery
		if (uart_fsm_state == UART_FSM_IDLE) {
			rx_buf_pos = 0;
		}
		check_uart_fsm(0,c);

		if (rx_buf_pos >= MSG_SIZE) {
			rx_buf_pos = 0;
		}
		rx_buf[rx_buf_pos++] = c;
	}

	// calculate checksum, and compare with received checksum
	uint8_t high, low;
	char checksum_ok, value_calc_flag;
	int checksum;
	if(uart_fsm_state == UART_FSM_END) { // reached state[CHECKSUM]
	  checksum = getCheckSum(rx_buf);
	  checksum_ok = (checksum == rx_buf[8]);

	  if (checksum_ok) {
		  printk("Checksum OK (%d == %d, index=%d)\n", checksum, rx_buf[8], rx_buf_pos);
	 
	    // check if we received all data and checksum is OK
	    value_calc_flag = (rx_buf_pos == MSG_SIZE);
	    if (value_calc_flag) {
        high = rx_buf[2];
        low = rx_buf[3];
        int ppm = (high * CO2_MULTIPLIER) + low;

        printk("CO2: %d ppm (high = %d, low = %d)\n", ppm , high, low);
        // print message buffer
        for (int i = 0; i < MSG_SIZE; i+=1) {
          printk("%x ", rx_buf[i]);
        }
        printk("\n");
      } else {
        printk("MSG not fully received\n");
      }
	  } else {
		  printk("Checksum failed (%d == %d, index=%d)\n", checksum, rx_buf[8], rx_buf_pos);
	  }

	  check_uart_fsm(1,0); // reset
	}
}

/**
 * Writes byte-per-byte (character, total 9 bytes) to myserial (device, CO2 sensor)
*/
void serial_write() {
	uint8_t tx_buf[MSG_SIZE] = {0xFF, 0x01, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79};
	for (int i = 0; i < MSG_SIZE; i+=1) {
		uart_poll_out(uart_serial, tx_buf[i]);
	}
}

// defines/initializes K_WORK queue and K_TIMER for UART
K_WORK_DEFINE(uart_work_que, uart_work_handler);
K_TIMER_DEFINE(uart_timer, uart_expiry_function, NULL);

int main(void) {
	if (!device_is_ready(uart_serial)) {
		printk("UART device not found!");
		return 0;
	}

	/* configure interrupt and callback to receive data */
	/*
	dev, device
	cb, callback
	user_data
	*/
	int ret = uart_irq_callback_user_data_set(uart_serial, serial_callback, NULL);

	if (ret != 0) {
		if (ret == -ENOSYS) {
      printk("UART IRQ function not implemented\n");
		} else if (-ENOTSUP) {
      printk("UART IRQ API not enabled\n");
    } else {
      printk("Error setting UART IRQ callback");
    }

    return 0;
	}

  uart_irq_rx_enable(uart_serial);

  k_timer_start(&uart_timer, K_SECONDS(1), K_SECONDS(1));

  return 0;
}
