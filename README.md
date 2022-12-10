# AoC

**TODO:** Flesh out the README

The code organization is very simple-minded -- almost all main driver functions are named `solve<day>_<part>`.
In general each of the drivers returns a different data type (either a string or an integer thus far). So, I exported a silly little convenience macro `@comptime` along with a generated function `solve`. So, you can call e.g. `solve7_1(input_string)` using
```julia
@comptime solve(7, 1)
```
