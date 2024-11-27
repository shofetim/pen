# This is Pen a simple markup system a la Scribe and Scribble


## Goals

- Small, self contained binary that is easy to install.
- Uses @ syntax.
  - Use @{} to wrap content that should be interpreted by pen.
  - Use @[] or @`` to pass raw, un-pen parsed text.
- To output a @ use @verbatim[@].
- HTML is the _sole_ target output.
- Optionally produce Janet data structures as an intermediate form.
- Ability to create a single page document (i.e. embed CSS). Which can be
  overridden with a supplied style sheet.
- Has a decent default appearance.
- No extension — just modify it to add more tags. All that is needed to add a
  new tag is to add it to env.janet. Call it as needed.
- Default tags include @pikchr.
- No html tag prefix.


## To-dos

- Support to build without template.
- Optionally produce Janet data structures as an intermediate form.


## Tags

The following just flow through to HTML

- blockquote
- center
- code
- dl
- dt
- dd
- ul
- ol
- li
- p
- em
- strong
- u
- pre
- sub
- sup
- tr
- td
- th
- hr


### Special

- aside: an "aside" block of text to the right of the main body.
- aside-l: an "aside" block of text to the _left_ of the main body.
- bigger: Wraps text in a span with styles that increases the font size.
- smaller: Wraps text in a span with styles that decreases the font size.
- image, img: Output image tags.
- html: Pass raw HTML out.
- codeblock: Outputs a codeblock.
- comment: Contents are not output.
- title: Document title, is both output with an h1 and is lifted to the document
  title metadata.
- link: Outputs an anchor tag.
- published: Outputs a span with a .published class.
- chapter: An un-numbered major section of a document.
- section: A number major section of the document.
- subsection: Numbered, subsection.
- subsubsection: Numbered, subsubsection.
- pikchr: Interpret the tag text as a [pikchr](https://pikchr.org/) script and return an SVG result.
- verbatim: The tag contents are passed through verbatim.
