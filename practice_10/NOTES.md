# Practice 10 notes

## Level 1: order of events
Expected: A, C, fetchStudents #1, (first frame), B, 6 students
Actual: A, C, fetchStudents #1, first frame, then after 2 seconds B and 6 students.
Nothing waited for the timer: main() ran to the end, the loop drew the screen, and the callbacks came later as events.

## Level 2: setState() after dispose()
Expected error: setState() called after dispose().
The screen was disposed, but an asynchronous operation tried to call setState() afterward.

## Level 4: countdown
Without cancel() (version B): I pressed Back at 7, the console kept printing tick 6, tick 5 ... tick 0 with nobody on screen, and showed setState() called after dispose(). That is the leak.
Version A (StreamBuilder): I pressed Back at 7, the console stopped at tick 7. There is no cancel() in my code, StreamBuilder cancelled the subscription itself.

## Level 5: lost error
The user saw a success (the screen closed), but the console said:
Unhandled Exception: Bad state: server rejected 6