;------------------------------------------------------------------------
; Implementation: Recursive Quicksort in LC-3 Assembly
; Purpose: Sorts an array of data using the Quicksort algorithm.
;------------------------------------------------------------------------

        .ORIG x3000

;--- Initialization ---
        LD  R6, STACKBASE    ; Initialize Stack Pointer (R6)
        
;--- Display Initial State ---
        LEA R0, MsgUnsort
        PUTS
        JSR PrintArray

;--- External Quicksort Entry ---
        ; Initial call parameters: low = 0, high = n-1
        AND R0, R0, #0       
        JSR Push             ; Push Low index
        
        LD  R0, n            
        ADD R0, R0, #-1
        JSR Push             ; Push High index
        
        AND R0, R0, #0       
        JSR Push             ; Reserve space for return value

        JSR Quicksort

        ; Clean up stack after top-level call
        ADD R6, R6, #3

;--- Display Result ---
        LD  R0, Newline
        OUT
        LEA R0, MsgSort
        PUTS
        JSR PrintArray

        HALT

;------------------------------------------------------------------------
; Subroutine: PrintArray
; Iterates through the array and prints characters followed by spaces.
;------------------------------------------------------------------------
PrintArray
        ST  R1, SaveR1_P     
        ST  R2, SaveR2_P
        ST  R0, SaveR0_P
        
        LEA R2, Data         ; Point to start of array
        LD  R1, n            ; Load total element count
        
LoopP   BRz EndLoopP
        LDR R0, R2, #0       ; Load current element
        OUT                  
        
        LD  R0, Space
        OUT
        
        ADD R2, R2, #1       ; Advance pointer
        ADD R1, R1, #-1      ; Decrement loop counter
        BR  LoopP
        
EndLoopP
        LD  R0, Newline
        OUT
        LD  R1, SaveR1_P     
        LD  R2, SaveR2_P
        LD  R0, SaveR0_P
        RET

;------------------------------------------------------------------------
; Subroutine: Quicksort
; Recursive logic for partitioning and sorting subarrays.
; Parameters (Stack): [R5+2] Low Index, [R5+1] High Index
;------------------------------------------------------------------------
Quicksort
        ; --- Prologue ---
        ADD R0, R7, #0
        JSR Push             ; Save Return Address
        ADD R0, R5, #0
        JSR Push             ; Save current Frame Pointer
        ADD R5, R6, #1       ; Establish new Frame Pointer

        ST  R1, SaveR1_Q     ; Save working registers
        ST  R2, SaveR2_Q
        ST  R3, SaveR3_Q
        ST  R4, SaveR4_Q

        ; --- Partition Logic ---
        LDR R1, R5, #2       ; R1 = low index
        LDR R2, R5, #1       ; R2 = high index

        ; Termination condition: if (low >= high) return
        NOT R3, R2
        ADD R3, R3, #1       ; R3 = -high
        ADD R3, R1, R3       ; R3 = low - high
        BRzp Q_End           

        ; Execute Partition(low, high)
        ADD R0, R1, #0
        JSR Push             ; Push parameter: low
        ADD R0, R2, #0
        JSR Push             ; Push parameter: high
        AND R0, R0, #0
        JSR Push             ; Placeholder for return (pivot index)
        
        JSR Partition
        
        JSR Pop              ; Capture pivot index into R0
        ADD R3, R0, #0       ; Maintain pivot in R3
        ADD R6, R6, #2       ; Clean parameters from stack

        ; Recursive call: quickSort(low, pivot - 1)
        ADD R0, R1, #0
        JSR Push             
        ADD R0, R3, #-1
        JSR Push             
        AND R0, R0, #0
        JSR Push
        JSR Quicksort
        ADD R6, R6, #3       

        ; Recursive call: quickSort(pivot + 1, high)
        ADD R0, R3, #1
        JSR Push             
        ADD R0, R2, #0
        JSR Push             
        AND R0, R0, #0
        JSR Push
        JSR Quicksort
        ADD R6, R6, #3       

Q_End   ; --- Epilogue ---
        LD  R1, SaveR1_Q
        LD  R2, SaveR2_Q
        LD  R3, SaveR3_Q
        LD  R4, SaveR4_Q
        JSR Pop
        ADD R5, R0, #0       ; Restore Frame Pointer
        JSR Pop
        ADD R7, R0, #0       ; Restore Return Address
        RET

;------------------------------------------------------------------------
; Subroutine: Partition
; Divides array into two parts based on a pivot (using high element).
;------------------------------------------------------------------------
Partition
        ADD R0, R7, #0
        JSR Push
        ADD R0, R5, #0
        JSR Push
        ADD R5, R6, #1

        ST  R1, SaveR1_PT
        ST  R2, SaveR2_PT
        ST  R3, SaveR3_PT
        ST  R4, SaveR4_PT

        LDR R1, R5, #2       ; i = low - 1
        ADD R1, R1, #-1
        LDR R4, R5, #2       ; j = low
        LDR R2, R5, #1       ; high

        ; pivot_value = Data[high]
        LEA R3, Data
        ADD R3, R3, R2
        LDR R3, R3, #0       

PT_Loop 
        ; Boundary check: if (j >= high) exit loop
        NOT R0, R2
        ADD R0, R0, #1
        ADD R0, R4, R0
        BRzp PT_EndLoop

        ; Comparison: if (Data[j] < pivot_value)
        LEA R0, Data
        ADD R0, R0, R4
        LDR R0, R0, #0       ; R0 = current element
        
        NOT R2, R3
        ADD R2, R2, #1       ; Negative pivot
        ADD R2, R0, R2       ; Delta
        BRzp PT_SkipSwap

        ; Element is smaller than pivot: increment i and swap
        ADD R1, R1, #1
        ADD R0, R1, #0
        JSR Push             ; Index 1
        ADD R0, R4, #0
        JSR Push             ; Index 2
        JSR Swap
        ADD R6, R6, #2

PT_SkipSwap
        LDR R2, R5, #1       ; Refresh high for loop logic
        ADD R4, R4, #1       ; j++
        BR PT_Loop

PT_EndLoop
        ; Final pivot placement: Swap(i + 1, high)
        ADD R1, R1, #1
        ADD R0, R1, #0
        JSR Push
        LDR R0, R5, #1
        JSR Push
        JSR Swap
        ADD R6, R6, #2

        ; Return final pivot position
        STR R1, R5, #0

        LD  R1, SaveR1_PT
        LD  R2, SaveR2_PT
        LD  R3, SaveR3_PT
        LD  R4, SaveR4_PT
        JSR Pop
        ADD R5, R0, #0
        JSR Pop
        ADD R7, R0, #0
        RET

;------------------------------------------------------------------------
; Subroutine: Swap
; Exchanges the values of two array indices.
;------------------------------------------------------------------------
Swap
        ST  R0, SaveR0_S
        ST  R1, SaveR1_S
        ST  R2, SaveR2_S
        ST  R3, SaveR3_S
        ST  R4, SaveR4_S

        LDR R1, R6, #5       ; Load Index 1
        LDR R2, R6, #4       ; Load Index 2

        LEA R0, Data
        ADD R3, R0, R1       ; Physical address of Data[idx1]
        ADD R4, R0, R2       ; Physical address of Data[idx2]

        LDR R1, R3, #0       
        LDR R2, R4, #0       

        STR R2, R3, #0       ; Write Val 2 to Idx 1
        STR R1, R4, #0       ; Write Val 1 to Idx 2

        LD  R0, SaveR0_S
        LD  R1, SaveR1_S
        LD  R2, SaveR2_S
        LD  R3, SaveR3_S
        LD  R4, SaveR4_S
        RET

;------------------------------------------------------------------------
; Stack Operations
;------------------------------------------------------------------------
Push    ADD R6, R6, #-1
        STR R0, R6, #0
        RET

Pop     LDR R0, R6, #0
        ADD R6, R6, #1
        RET

;------------------------------------------------------------------------
; Constants and Storage
;------------------------------------------------------------------------
STACKBASE .FILL xFD00
Space     .FILL x0020
Newline   .FILL x000A
MsgUnsort .STRINGZ "Unsorted Data: "
MsgSort   .STRINGZ "Sorted Data:   "

; Subroutine Register Save Slots
SaveR0_P .BLKW 1
SaveR1_P .BLKW 1
SaveR2_P .BLKW 1
SaveR0_S .BLKW 1
SaveR1_S .BLKW 1
SaveR2_S .BLKW 1
SaveR3_S .BLKW 1
SaveR4_S .BLKW 1
SaveR1_Q .BLKW 1
SaveR2_Q .BLKW 1
SaveR3_Q .BLKW 1
SaveR4_Q .BLKW 1
SaveR1_PT .BLKW 1
SaveR2_PT .BLKW 1
SaveR3_PT .BLKW 1
SaveR4_PT .BLKW 1

;--- Data Set ---
n       .FILL #12            ; Number of elements
Data    .FILL x4C            ; L
        .FILL x43            ; C
        .FILL x33            ; 3
        .FILL x53            ; S
        .FILL x4F            ; O
        .FILL x52            ; R
        .FILL x54            ; T
        .FILL x45            ; E
        .FILL x58            ; X
        .FILL x41            ; A
        .FILL x4D            ; M
        .FILL x50            ; P

        .END