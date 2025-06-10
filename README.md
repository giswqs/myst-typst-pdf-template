# myst-typst-pdf-template

A template for compiling typst to pdf

## Instructions

1. Install the required packages: `pip install requirements.txt`
2. Add your MyST markdown files
3. Make sure your markdown files have proper frontmatter
4. Run `myst build --typst`
5. Find the generated PDF under ` _build/exports`
6. Go to `_build/temp/` and run `find . -type f -exec sed -i 's/width: 90%/width: 100%/g' {} +` to change image width from 90% to 100%
7. Find the typst file under `_build/temp/` and run `typst compile filename.typ`
8. Locate the generated PDF under the same directory
