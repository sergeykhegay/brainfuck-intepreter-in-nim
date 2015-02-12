import macros

dumpTree:
  while tape[tapePos] != '\0':
    inc tapePos

proc compile(code: string): PNimrodNode {.compiletime.} =
    var stmts = @[newStmtList()]

    template addStmt(text): stmt =
        stmts[stmts.high].add parseStmt(text)

    addStmt "var tape: array[1_000_000, char]"
    addStmt "var tapePos = 0"

    for c in code:
        case c
        of '+': addStmt "inc tape[tapePos]"
        of '-': addStmt "dec tape[tapePos]"
        of '>': addStmt "inc tapePos"
        of '<': addStmt "dec tapePos"
        of '.': addStmt "stdout.write tape[tapePos]"
        of ',': addStmt "tape[tapePos] = stdin.readChar"
        of '[': stmts.add newStmtList()
        of ']':
            var loop = newNimNode(nnkWhileStmt)
            loop.add parseExpr("tape[tapePos] != '\\0'")
            loop.add stmts.pop
            stmts[stmts.high].add loop
        else: discard

    result = stmts[0]
    echo result.repr

static:
    discard compile "+>+[-]>,."

macro compileString*(code: string): stmt =
    ## Compiles the brainfuck `code` string into Nim code that reads from stdin
    ## and writes to stdout.
    compile code.strval

macro compileFile*(filename: string): stmt =
    ## Compiles the brainfuck code read from `filename` at compile time into Nim
    ## code that reads from stdin and writes to stdout.
    compile staticRead(filename.strval)


proc mandelbrot = compileFile "examples/mandelbrot.b"

mandelbrot()

