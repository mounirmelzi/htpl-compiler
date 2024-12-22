# HTPL Compiler

This project contains an `HTPL` (**H**yper**T**ext **P**rogramming **L**anguage) Compiler for processing `HTPL` programs.

## Project Authors

- **M**ELZI **M**ounir
- **D**JEDJIG **N**ada **F**arah
- **B**OUHADI **H**aifaa
- **G**UEDDOUCHE **R**ania

## Prerequisites

- Linux environment
- Latest version of Flex and Bison
- Latest version of GCC

## Installation and Usage

### Cloning the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### Running the Compiler

#### Default Execution

Navigate to the scripts folder and run the default script:

```bash
cd scripts
./run
```

This will run the compiler on the default htpl program located in the examples folder.

#### Custom File Compilation

To compile a custom file, use:

```bash
./run <filename>
```

Replace `<filename>` with the path to your HTPL source file.

## Notes

- Ensure you have the latest versions of Flex, Bison and GCC installed
- The compiler is designed to work in a Linux environment
