#!/bin/sh

jpm clean; jpm build; ./build/pen-to-typst sample.pen && echo "" && echo "" && echo "" && cat sample.typ
