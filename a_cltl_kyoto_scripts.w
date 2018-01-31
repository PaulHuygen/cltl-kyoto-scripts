\documentclass[twoside]{rapport3}
\pagestyle{headings}
\usepackage{figlatex}
\usepackage{makeidx}
\renewcommand{\indexname}{General index}
\makeindex
\title{Scripts on \texttt{kyoto.let.vu.nl}}
\author{Paul Huygen}
\date{\today}
\begin{document}
\maketitle
\begin{abstract}
this document contains scripts that can perform useful tasks in \texttt{kyoto.let.vu.nl}.
\end{abstract}
\tableofcontents

\chapter{The Makefile}
\label{chap:makefile}

@o Makefile @{@%
nuwebsource = cltl_kyoto_scripts.w

m4_projname<!!>.w : m4_<!!>m4_progname<!!>.w inst.m4
        m4 -P m4_<!!>m4_progname<!!>.w > m4_progname<!!>.w



sources : 
@| @}


\end{document}