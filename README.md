# Latexdiff.el

[![MELPA](http://melpa.milkbox.net/packages/latexdiff-badge.svg)](http://melpa.milkbox.net/#/latexdiff)

Latexdiff.el is a backend in Emacs for [Latexdiff](https://github.com/ftilmann/latexdiff).

![Demonstration](https://raw.githubusercontent.com/galaunay/latexdiff.el/master/doc/latexdiff.gif)

## Requirements

latexdiff.el requires Emacs-24.4 or later
and optionnaly [Helm](https://github.com/emacs-helm/helm).

## Install

#### Installing latexdiff

Install `latexdiff` from your package manager or from
[the official website](https://github.com/ftilmann/latexdiff).
latexdiff.el uses `latexdiff-vc' so make sure it is available.

#### Installing latexdiff.el from MELPA

If you already use MELPA, all you have to do is:

    M-x package-install RET latexdiff RET

For help installing and using MELPA, see [these instructions](
http://melpa.milkbox.net/#/getting-started).

#### Installing latexdiff.el from git

  1. Clone the `latexdiff` repository:

```bash
    $ git clone https://github.com/galaunay/latexdiff.el.git /path/to/latexdiff/directory
```

  2. Add the following lines to `.emacs.el` (or equivalent):

```elisp
    (add-to-list 'load-path "/path/to/latexdiff/directory")
    (require 'latexdiff)
```

## Configuration

latexdiff.el faces and behaviour can be customized through the customization panel :

```elisp
(customize-group 'latexdiff)
```

latexdiff.el does not define default keybindings, so you may want to add
some :

```elisp
(define-key latex-mode-map (kbd "C-c l d") 'helm-latexdiff)
```

or for Evil users:

```elisp
(evil-leader/set-key-for-mode 'latex-mode "ld" 'helm-latexdiff)
```

## Basic usage

### File to file diff:

- `latexdiff` will ask for two tex files and generates a tex diff between
  them (that you will need to compile).

### Version diff (git repo only):

- `latexdiff-vc` (and `helm-latexdiff-vc`) will ask for a previous commit
  number and make a pdf diff between this version and the current one.
- `latexdiff-vc-range` (and `helm-latexdiff-vc-range`) will ask for two
  commits number and make a pdf diff between those two versions.

## Contributing

The project is hosted on [github](https://github.com/galaunay/latexdiff.el).
You can report issues or make pull requests here.

To run the tests you will need to install cask, then:

```bash
$ make test
```

## Todo
 - Add support for other version-control software (currently only git repositories are supported, while latexdiff can handle more).
