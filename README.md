pandoc-tex2svg
==============

pandoc-tex2svg is a pandoc filter that renders math as SVG.
It can be used with HTML5 based output formats, including
EPUB and HTML-based slide shows like reveal.js.

Here's an example of its output:
[math-samples.html](math-samples.html).

The filter uses `tex2svg` from
[MathJax-node](https://github.com/mathjax/MathJax-node).
To install using npm,

    npm install -g mathjax-node

`tex2svg` is assumed to be in the path.  Note that the default
install does not put it in the path; you will have to do this
manually.

To compile and install the filter:

    stack install

or

    cabal install

Make sure the filter is in your path (stack puts executables in
`$HOME/.local/bin`).

To use the filter with pandoc (currently pandoc 1.18 is required):

    pandoc math-samples.md --filter pandoc-tex2svg -s -t html5 -o math-samples.html

The filter is rather slow, and it adds significantly to file
size, but the resulting HTML renders quickly and does not depend
on an internet connection or JavaScript.

Thanks to Kolen Cheung for the suggestion.

