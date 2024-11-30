# HTPL Compiler

## Overview

This project contains an HTPL (HyperText Programming Language) Compiler for processing HTPL programs.

## Prerequisites

- Linux environment
- Latest version of Flex
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

- Ensure you have the latest versions of Flex and GCC installed
- The compiler is designed to work in a Linux environment
