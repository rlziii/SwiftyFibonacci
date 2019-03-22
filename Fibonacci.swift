import Foundation

/// A helper function that measures the time it takes to run another function
/// (supplied as an argument) and prints out that time to the console/terminal.
/// The function to be measured is provided as a closure to this function.
///
/// Example usage:
///     benchmark {
///         /* some logic here */
///     }
///
/// Example result:
///     Elapsed time: 5 milliseconds
///
/// - Parameter method: The code to be measured. This must be a void function,
///                     meaning that it cannot return anything.
func benchmark(method: () -> Void) {
    let startTime = DispatchTime.now().uptimeNanoseconds
    method()
    let endTime = DispatchTime.now().uptimeNanoseconds

    // Note the use of `1e6`; this is simply shorthand for 1000000
    // (which itself can be more clearly written as 1_000_000).
    let elapsedTime = Double(endTime - startTime) / 1e6
    print("Elapsed time: \(elapsedTime) milliseconds")
}

/// A recursive function to calculate a given number in the Fibonacci sequence.
///
/// Note: This version of the Fibonacci sequence is very simple and easy to read
///       and follow; however, it is horribly inefficient as we start to
///       calculate larger values in the sequence. This is because each time
///       a number is calculated, a recursive call to the function has to repeat
///       a lot of computation to reach the desired number. For example, just
///       trying to calculate the fifth Fibonacci number will require 19 calls!
///       This is known as a top-down approach because we are starting with the
///       number we wish to calculate at the top and moving down to calculate
///       the needed values.
///
/// Diagram:
///                      5
///                 ____/ \____
///                /           \
///               2             3
///              / \           / \
///             /   \         /   \
///            1     1       /     \
///           / \   / \     1       2
///          0   1 0   1   / \     / \
///                       0   1   /   \
///                              1     1
///                             / \   / \
///                            0   1 0   1
///
/// - Parameter n: The number in the Fibonacci sequence to calculate.
///
/// - Returns: The desired Fibonacci number.
func fibRecursive(_ n: Int) -> Int {
    // If `n` is a number that is not greater than 1, then simply return it as
    // the solution itself. This is because the 0th Fibonacci number is 0 and
    // the 1st Fibonacci number is 1.  This is necessary in the recursive
    // version of this algorithm because it acts as the "base case," essentially
    // the condition that stops the recursion from going on forever!
    guard n > 1 else {
        return n
    }

    return fibRecursive(n - 1) + fibRecursive(n - 2)
}

/// An iterative function to calculate a given number in the Fibonacci sequence.
///
/// Note: This version of the Fibonacci sequence is very similar to the
///       recursive version in structure, however it is WAY more efficient by
///       using an array to keep track of the previous values to iterate over.
///       Because of this there is no repeated computation needed. This is known
///       as a bottom-up approach because we are starting with the smallest
///       Fibonacci numbers at the bottom and building our way up to the desired
///       number in the sequence.
///
/// - Parameter n: The number in the Fibonacci sequence to calculate.
///
/// - Returns: The desired Fibonacci number.
func fibIterative(_ n: Int) -> Int {
    guard n > 1 else {
        return n
    }

    var fibArray = [0, 1]

    // Here we start at 2 because we already have indices 0 and 1 of the array.
    for i in 2...n {
        fibArray.append(fibArray[i - 1] + fibArray[i - 2])
    }

    return fibArray[n]
}

/// A memoize function to calculate a given number in the Fibonacci sequence.
///
/// Note: This version of the Fibonacci sequence is very similar to the
///       iterative version, but it does not need keep hold of an entire array
///       to calculate the next number.  Instead, this version only keeps track
///       of two numbers.  This works because it takes advantage of the fact
///       that to calculate the next number in the Fibonacci sequence, only the
///       two previous numbers are actually needed.  So starting from the two
///       smallest Fibonacci numbers (0 and 1), we build are way up to the
///       number for which we desire.
///
/// - Parameter n: The number in the Fibonacci sequence to calculate.
///
/// - Returns: The desired Fibonacci number.
func fibMemoize(_ n: Int) -> Int {
    guard n > 1 else {
        return n
    }

    // Here we are using a tuple instead of two different variables.
    // There does not gain any real performance, but allows for a more "Swifty"
    // structure to hold these two values.
    var (a, b) = (0, 1)

    // We are using `stride(from:to:by:)` so that we are "skip" by twos.
    // Essentially since we are updating both values at the same time, we only
    // need to go through every other iteration of the for loop.
    for _ in stride(from: 1, to: n, by: 2) {
        a = a + b
        b = a + b
    }

    // If `n` happened to be an even number, then we return the first value.
    // Otherwise if the `n` was odd we return the second value. With the
    // following example it is easy to see why this is always the case.
    //
    // Example:
    //     If `n` is 6, we calculate the following:
    //         1st loop: a = 0, b = 1  (0th and 1st numbers in the sequence)
    //         2nd loop: a = 1, b = 2  (2nd and 3rd numbers in the sequence)
    //         3rd loop: a = 3, b = 5  (4th and 5th numbers in the sequence)
    //         4th loop: a = 8, b = 13 (6th and 7th numbers in the sequence)
    //                   ^
    //                   |_ Therefore this is the number we want.
    //
    //     If `n` is 7, we calculate the following:
    //         1st loop: a = 0, b = 1  (0th and 1st numbers in the sequence)
    //         2nd loop: a = 1, b = 2  (2nd and 3rd numbers in the sequence)
    //         3rd loop: a = 3, b = 5  (4th and 5th numbers in the sequence)
    //         4th loop: a = 8, b = 13 (6th and 7th numbers in the sequence)
    //                          ^
    //                          |_ Therefore this is the number we want.
    //
    // Note that this does mean sometime we calculate an extra, unneeded value.
    return n % 2 == 0 ? a : b
}

/// A memoize function to calculate a given number in the Fibonacci sequence.
///
/// Note: An optimized version of `fibMemoize(_:)` by removing the use of
///       `stride(from:to:by:)`, which happened to be quite slow in our use
///       case.  This is clearly less "Swifty," but is quite a bit faster.
///
/// - Parameter n: The number in the Fibonacci sequence to calculate.
///
/// - Returns: The desired Fibonacci number.
func fibMemoizeOptimized(_ n: Int) -> Int {
    guard n > 1 else {
        return n
    }

    var (a, b) = (0, 1)

    // Instead of using `stride(to:from:by:)`, which is slower than desired, we
    // use a more traditional for loop.  Instead of "skipping" loops, we simply
    // only go through half the amount of necessary loops since we are doing two
    // operations per iteration. While this does not always show a gain in small
    // Fibonacci calculations, it shows a GREAT improvement when calculating
    // larger values.
    for _ in 1...(n / 2) {
        a = a + b
        b = a + b
    }

    return n % 2 == 0 ? a : b
}

// The number in the Fibonacci sequence that we wish to calculate.
// Be careful here because integer overflow occurs at just the 91st number, so
// anything larger will not give the correct value.
let n = 90

// We have a check here because for large numbers the recursive solution can
// take a very long time to complete!
if n < 35 {
    //
    benchmark {
        // The first empty line is here is here simply for formatting.
        print()
        print("fibRecursive: \(fibRecursive(n))")
    }
}

benchmark {
    // The first empty line is here is here simply for formatting.
    print()
    print("fibIterative: \(fibIterative(n))")
}

benchmark {
    // The first empty line is here is here simply for formatting.
    print()
    print("fibMemoize: \(fibMemoize(n))")
}

benchmark {
    // The first empty line is here is here simply for formatting.
    print()
    print("fibMemoizeOptimized: \(fibMemoizeOptimized(n))")
}
