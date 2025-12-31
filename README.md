# Assembly Quicksort

A recursive implementation of the Quicksort algorithm in LC-3 assembly language, demonstrating low-level sorting operations, stack management, and subroutine conventions.

## Overview

This project implements the classic Quicksort algorithm entirely in LC-3 assembly.  It showcases fundamental computer architecture concepts including:
- Recursive function calls using stack frames
- Register management and context preservation
- Array manipulation at the assembly level
- Partition-based sorting logic

The program sorts an array of ASCII character values and displays both the unsorted and sorted results.

## Features

- **Recursive Quicksort**: Full implementation of the divide-and-conquer sorting algorithm
- **Stack-Based Execution**: Proper stack frame management for recursive calls
- **In-Place Sorting**: Sorts array elements without requiring additional memory
- **Visual Output**:  Displays unsorted and sorted arrays for verification
- **Register Preservation**:  Follows LC-3 calling conventions with proper register save/restore

## Algorithm Details

### Quicksort Logic

The implementation follows the standard quicksort approach: 

1. **Base Case**: If the subarray has ≤ 1 element, return
2. **Partition**: Rearrange elements so that: 
   - Elements less than the pivot are on the left
   - Elements greater than the pivot are on the right
3. **Recursive Sort**: Recursively sort the left and right subarrays

### Partition Strategy

- **Pivot Selection**: Uses the last element as the pivot (high index)
- **Two-Pointer Technique**: Maintains an index `i` for elements less than the pivot
- **In-Place Swapping**: Exchanges elements to maintain partition invariant

## Program Structure

### Main Routine
1. Initialize stack pointer
2. Display unsorted array
3. Call Quicksort with initial parameters (low=0, high=n-1)
4. Display sorted array
5. Halt execution

### Subroutines

| Subroutine | Purpose | Parameters |
|------------|---------|------------|
| `Quicksort` | Recursive sorting routine | Low index, High index (via stack) |
| `Partition` | Partitions array around pivot | Low index, High index (via stack) |
| `Swap` | Exchanges two array elements | Two array indices (via stack) |
| `PrintArray` | Displays array contents | None |
| `Push` | Pushes value onto stack | Value in R0 |
| `Pop` | Pops value from stack | Returns in R0 |

## Sample Data

The program sorts 12 ASCII characters representing "LC3SORTEXAMP": 

```
Unsorted:  L C 3 S O R T E X A M P
Sorted:   3 A C E L M O P R S T X
```

## Running the Program

### Prerequisites
- LC-3 simulator (e.g., LC-3 Tools, PennSim, or similar)
- Basic understanding of LC-3 assembly language

### Execution Steps

1. **Load the program:**
   ```
   Load quicksort.asm into your LC-3 simulator
   ```

2. **Set the starting address:**
   ```
   PC = x3000
   ```

3. **Run the program:**
   ```
   Execute until HALT instruction
   ```

4. **View output:**
   The console will display:
   ```
   Unsorted Data: L C 3 S O R T E X A M P 
   Sorted Data:   3 A C E L M O P R S T X
   ```

## Memory Layout

```
x3000         Program code starts
xFD00         Stack base (grows downward)
Data section  Array storage and constants
```

### Key Memory Locations

- **STACKBASE**: `xFD00` - Initial stack pointer
- **Data**:  Array of 12 elements (ASCII characters)
- **n**: Array size (12)
- **SaveR***:  Register preservation slots for each subroutine

## Technical Implementation

### Stack Frame Structure

Each recursive call maintains a stack frame containing:
```
[R5+3]  Parameter:  Low index
[R5+2]  Parameter: High index
[R5+1]  Saved frame pointer
[R5+0]  Return address
[R5-1]  Return value (for Partition)
```

### Register Usage Conventions

| Register | Purpose |
|----------|---------|
| R0 | Temporary values, function arguments |
| R1-R4 | Working registers (saved/restored) |
| R5 | Frame pointer |
| R6 | Stack pointer |
| R7 | Return address |

### Calling Convention

1. **Caller**:
   - Push parameters onto stack (right to left)
   - Reserve space for return value
   - JSR to subroutine
   - Clean up stack after return

2. **Callee**:
   - Save return address and frame pointer
   - Establish new frame pointer
   - Save working registers
   - Execute function logic
   - Restore registers and return

## Algorithm Complexity

- **Time Complexity**:
  - Best/Average Case: O(n log n)
  - Worst Case: O(n²) - occurs when array is already sorted
  
- **Space Complexity**: O(log n) - stack depth for recursive calls

- **In-Place**:  Yes - sorts within the original array

## Customization

### Modifying the Dataset

To sort different values, modify the `Data` section:

```assembly
n       .FILL #<number_of_elements>
Data    . FILL x<hex_value_1>
        .FILL x<hex_value_2>
        ; ... add more elements
```

**Note**: The values should be ASCII characters for proper display using the `OUT` instruction.

### Changing Array Size

Update the `n` constant to match your array size: 
```assembly
n       .FILL #<new_size>
```
