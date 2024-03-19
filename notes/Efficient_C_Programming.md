“It is more efficient to use the int type for function arguments and return values, even if you are only passing an 8-bit value.”
* This is because most ARM data processing operations are 32-bit only. Passing smaller data types (e.g. char or short) require “narrow”-ing
* Narrowing is simply the process of explicitly casting to a smaller data type.

