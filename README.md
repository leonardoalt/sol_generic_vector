# Solidity Generic Vector

Solidity does not yet have generics, which makes it hard to have data
structures such as vectors.
This repo contains different attempts at building an evolving library for
generic vectors in Solidity.

The main result is a sort of generic vector library based on assembly runtime
type casts.

It is **not** ready for production.

**tl;dr**: The generic vector based on assembly runtime casts is in
`src/GenericVector.sol`. Its usage for specific types such as `uint` and a `struct`
can be seen in `src/GenericVectorUInt.sol`, `src/test/GenericVectorUInt.t.sol`,
`src/GenericVectorStruct.sol`, and `src/test/GenericVectorStruct.t.sol`.
If you want a full explanation of what's happening here, keep reading.
Otherwise, jump into the code!

To run all tests:
```
$ forge test
```

# Basic Vector

The API of the Vector we are creating is quite simple, and follows what many
other languages have in their standard libraries:

- Allocate a vector with a certain amount of reserved elements.
- Reserve/allocate more elements.
- Push a new element at the end.
- Pop the last element.
- Change the element at a valid index.
- Query an index.
- Query the length.

The implementation also follows other languages:

- We start by allocating either a required amount of elements, or a constant small size.
- If pushing a new element requires more memory, we allocate twice the number of elements
  the vector currently has, and move the existing elements to the new region.
- Popping an element simply decreases the length of the array.

# Vector Implementations

There are a few different Vector implementations here:

## Two non-generic `uint` Vectors

1) File `VectorUInt.sol` contains a Vector for `uint`s that is not generic and not
optimized for gas. This code aims at being as clean and readable as possible.
The Vector data structure consists of a simple `struct` containing a `uint[]
data`, and the currently used `length`.
The amount of reserved elements can be retrieved from `data.length`.
Since `data` is a memory pointer, whenever we need to expand it we simply
allocate a new region and point `data` there.
The implementation pretty much follows the paragraph above.

2) The second implementation comes from [@brockelmore](https://github.com/brockelmore) 's
[full assembly implementation](https://gist.github.com/brockelmore/2904cf497a4af63d403ae1666805f42d).

Test file `FullPushableUInt.t.sol` has a test function using the two libraries
above. The second one uses about 4x times less gas on that test, which is
somewhat expected.

To run that comparison:
```
$ forge test -m "full_pushable"
```

## A generic Vector based on runtime type casts

File `GenericVector.sol` contains a library that uses assembly runtime type
casts to make the vector generic over the type of its elements, trying to use
as little assembly as possible to keep readability.
Instead of keeping a Solidity array pointer of the desired type, our new
`struct Vector` has the plain bytes data, the memory size of one base element,
and the used and reserved amount of elements.
The allocation and expansion ideas are implemented similarly to the non-generic
vector.

The generic part of this library comes from the fact that function `push` takes
plain `bytes` as the element to be pushed, and function `at` returns plain
`bytes` as the requested element.

File `GenericVectorUInt.sol` contains the specific part of how to
instantiate a `UInt` vector using the generic library. One needs to define the
base size of an element and a `struct` that wraps the base type.
The runtime cast parts are present in functions `push` and `at`.
Function `push` needs to take the element in its desired type, here an `uint`,
and pass it as raw bytes to the generic implementation which does the actual
push. Reversely, function `at` needs to take the queries element in bytes
and return an `uint`.
File `GenericVectorStruct.sol` contains the analogous for a `struct`.

Ideally the specific implementation would be as simple as that. Unfortunately,
we still need to list the other library functions, relaying them to the generic
implementation. Ideally we could just add `using VectorUIntImpl for Vector;`
and be done with it, but we would not have access to the other library
functions.  Adding `using GenericVectorImpl for Vector;` could fix that, but
the compiler complains that both `at` functions have the same input parameter
types, so we would need to split `at` into its own library. Therefore, relaying
the other functions felt the simplest to me.

The current implementation always keeps all data in place. It currently only
works for value types and structs that do not contain arrays.

### Gas Comparison: non-generic vs generic `uint` vector

The tests `test_vector_uint` and `test_generic_vector_uint` run the same
functionalities.
The generic one uses about 1.5x as much gas as the non-generic one.
I'm sure there are optimizations that can be made to lower that ratio, maybe
even implement the generic library fully in assembly.

I'll leave that to the assembly optimizoors.

## A generic Vector based on ABI encode/decode

As a last comparison item, here we also have a generic vector library in
`src/GenericVectorABI.sol` which is similar to the one above, with the
difference that it does not use assembly at all.
Instead of runtime type casts, we ABI encode the typed data into the raw bytes
that are stored, and decode it back into the desired type when an element is
queried.
In my opinion this is the cleanest runtime approach, of course to the expense
of gas.
Test `test_generic_vector_abi` does the same as the two in the comparison
above, and uses 25x as much gas as the type cast generic library.
