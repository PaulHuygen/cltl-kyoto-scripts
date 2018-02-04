m4_include(inst.m4)m4_dnl
\documentclass[twoside]{artikel3}
\newcommand{\theTitle}{m4_doctitle}
\newcommand{\theAuthor}{m4_author}
\input{thelatexheader.tex}
\begin{document}
\maketitle
\begin{abstract}
  this document describes and generates scripts that are useful.
\end{abstract}

\section{Pipeline}
\label{sec:pipeline}

\subsection{Restore the eSRL server}
\label{sec:restore_eSRL}

It turns out that the server for `eSRL` module may stop to work as
advertised. An example of an error message that is caused by a
corrupted `eSRL` server:

\begin{verbatim}
java.net.SocketException: Connection reset
        at java.net.SocketInputStream.read(SocketInputStream.java:196)
        at java.net.SocketInputStream.read(SocketInputStream.java:122)
        at java.net.SocketInputStream.read(SocketInputStream.java:210)
        at java.io.DataInputStream.readBoolean(DataInputStream.java:242)
        at ixa.srl.SRLClient.main(SRLClient.java:70)
Completed: module /usr/local/share/pipelines/nlpp/bin/eSRL; result 0

\end{verbatim}

The problem can be solved by shutting down the \verb|eSRL| server. To this
end there is a script \verb|kill_eSRL_server| that does this, provided the
issuer belongs to the ``sudo'' group.

m4_define(m4_eSRLport, 5005)m4_dnl
This script does the following: First it finds out which process listens on
the port on which \verb|eSRL| listens, i.e. port m4_eSRLport. The it
checks whether the command-line instruction for that process is indeed
command to start the eSRL server. If that is the case, the script
kills the process. The Next time that
\verb|nlpp| runs it will automatically  start a new \verb|eSRL|
server. 

To find out whether a process listen on port m4_eSRLport and, if so, what the
ID of that process is, the script issues the \verb|netstat|
command. This command produces a line that looks like

\begin{verbatim}
tcp 0 0 0.0.0.0:m4_eSRLport 0.0.0.0:* LISTEN 29891/java | 

\end{verbatim}

The process-id of the listener is located before the string
\verb|/java|. The following \verb|awk| script extracts that number:

@d define awk-script to extract eSRL process-id @{@%
awkscript='{match($7, /([[:digit:]]+)\/[.]*/, arr); print arr[1]}'
@| @}

The command that starts the \verb|eSRL| server has form like:

\begin{verbatim}
java -Xms2500m -cp \
/usr/local/share/pipelines/nlpp/modules/EHU-srl-server/IXA-EHU-srl-3.0.jar ixa.srl.SRLServer en

\end{verbatim}

The command can be read from e.g. \verb|/proc/29891/cmdline|. The
script looks whether the string \verb|SRLServer| appear in that line.

@o m4_bindir/kill_eSRL_server @{@%
#!/bin/bash
@% procnum=`netstat -tulpn 2>/dev/null | grep m4_eSRLport | gawk '{match($7, /([[:digit:]]+)\/[.]*/, arr); print arr[1]}'`
@< define awk-script to extract eSRL process-id @>
procnum=`netstat -tulpn 2>/dev/null | grep m4_eSRLport | gawk "$awkscript"`
grep SRLServer /proc/$procnum/cmdline
res=$?
if
    [ $res == 0 ]
then
    echo process found: $procnum
    sudo kill $procnum
else
    echo eSRL process not found
fi
@| @}




\end{document}
