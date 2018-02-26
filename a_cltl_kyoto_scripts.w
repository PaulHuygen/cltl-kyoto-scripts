m4_include(inst.m4)m4_dnl
m4_sinclude(local.m4)m4_dnl
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

\section{Web-resources}
\label{sec:webresources}

\subsection{Implement a demo-app}
\label{sec:demo-app}

The following is actually a script in \verb|cltl.nl|, not in
\verb|kyoto.let.vu.nl|. It serves to install a flask app in
\verb|demo.nl|.

It is possible to install a flask app in such a way, that  it can be
reached as e.g. \verb|demo.cltl.nl/my_app|. There are certain
restrictions to this method:

\begin{itemize}
\item The app must run on Anaconda as installed in
  \verb|/usr/local/share/anaconda|. However, it is possible to
  generate a virtual environment that is derived from this Anaconda
  application.
\item It must be made sure that internal references to the app use the
  correct \textsc{url}, including the \verb|my_app| subdirectory.
\end{itemize}

To install such an app, there exists the following script
\verb|add_flask_demo|. The script works as
follows:

\begin{itemize}
\item It generates a \verb|wsgi| script in directory
  \verb|/usr/local/demo_wsgi| that activates the app.
\item It generates an instruction in the configuration file for site
  \verb|demo.cltl.nl| that installs the \verb|wsgi| script as
  \verb|WSGIScriptAlias|. 
\end{itemize}

Suppose you have a Flask app \verb|appdir/my_app.py| and you want to
connect it to \textsc{url} \verb|demo.cltl.nl/the_app|, then invoke
the script with the following command:

\begin{alltt}
  sudo add_flask_demo -n the_app appdir/my_app
\end{alltt}

The script will perform the following:

\begin{enumerate}
\item Generate a \verb|wsgi| script in directory
  \verb|/usr/local/share/demo_wsgi| that starts your script.
\item \begin{sloppypar}
       Include a \verb|WSGIScriptAlias| in the configuration file for
       the site \verb|demo.cltl.nl|
       (i.e.\ \verb|/etc/apache2/sites-available/m4_siteconfigfile|).
      \end{sloppypar}
\end{enumerate}

What the script does is described in the help function:

@d help function of add\_flask\_demo @{@%
#Help function
function HELP {
  echo -e \\n"${SCRIPT} -- Publish a Flask demo on ${UL}demo.cltl.nl${NORM}"\\n
  echo -e "${BOLD}Usage:${NORM}"
  echo -e "${SCRIPT} [ -n NAME ] [ -v VENV ] FILE"
  echo -e "${SCRIPT} -h"\\n
  echo -e "FILE   Python script with flask app."
  echo -e "-n     Give the demo another name than that of the Python file"
  echo -e "-v     Use virtual environment VENV instead of host environment."
  echo -e "-h     Display this help message."\\n
  echo -e "Example: ${BOLD}$SCRIPT -n super -v mydemo/venv mydemo/mydemo.py ${NORM}"
  echo -e "         publishes app in ${UL}mydemo.py${NORM} as  ${UL}demo.cltl.nl/super${NORM}"\\n
}

@| @}

\subsubsection{Set up the app}
\label{sec:setup}

Generate a \verb|wsgi| file that performs the following:

\begin{itemize}
\item Activate a virtual environment if that is requested by the option \verb|-v|;
\item Add the directory of the app to the \verb|PATH| variable;
\item Invoke the app. 
\end{itemize}

If the user provided a \verb|-v| option, variable \verb|virtenv| has
been set. From
\href{https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash}{Stack-overflow}
we learn that the best way to check whether a variable \verb|var| has been set is
to test expression ``\verb|! -z ${var}|''.

When a virtual environment ought to be used, have the \verb|wsgi|
script to execute the full path to the Python script
\verb|activate_this.py|. I am sorry, but I forgot from where I stole
this code.

@d build the wsgi file @{@%
rm -f $WSGI_DIR/$wsgi_filename
if
  [ ! -z ${virtenv} ]
then
  virtenv_full="$( cd $virtenv && pwd)"
@%   cat >$WSGI_DIR/$wsgi_filename <<EOF
@% activate_this = '$virtenv_full/bin/activate_this.py'
@% with open(activate_this) as file_:
@%     exec(file_.read(), dict(__file__=activate_this))
@% EOF
  @< wsgi-line @(activate_this = '$virtenv_full/bin/activate_this.py'@) @>
  @< wsgi-line @(with open(activate_this) as file_:@) @>
  @< wsgi-line @(    exec(file_.read(), dict(__file__=activate_this))@) @>
fi
@|virtenv @}

Note that writing quotes with the Bash \verb|echo| command is
difficult. To write a string that contains single quote characters
(\verb|'|), I found out that it works to wrap the string to be written
in double quote characters (\verb|"|) and not escape the single quote.

@d wsgi-line @{@%
  echo "@1" >> $WSGI_DIR/$wsgi_filename
@| @}



Start the app in the \verb|wsgi| file.

@d build the wsgi file @{@%
@% cat >>$WSGI_DIR/$wsgi_filename <<EOF
@% import sys
@% sys.path.insert(0, '$demo_dir')
@% from $demo_filename_without_py import app as application
@% EOF
@< wsgi-line @(import sys@) @>
@< wsgi-line @(sys.path.insert(0, '$demo_dir')@) @>
@< wsgi-line @(from $demo_filename_without_py import app as application@) @>
@| @}

Add a \verb|WSGIScriptAlias|%
\index{WSGIScriptAlias}
statement to the site-config-file for
Apache. In this file there is a line with text
\verb|Here the WSGIScriptAliases|.
Put the \verb|WSGIScriptAlias| right under this
line. The following \verb|AWK| script performs this:

@% @d awkscript @{@%
@% { print }
@% /Here the WSGIScriptAliases/ {
@%   printf( "    WSGIScriptAlias /%s %s/%s\n", demo_name, WSGI_DIR, wsgi_filename )
@% }
@% @| @}


Modify the Apache config-file. This has to be done carefully. If
something is wrong, Apache might not work anymore causing all the sites
that this host supports to drop out of the air. Therefore we
proceed as follows:

\begin{itemize}
\item Copy the existing Apache config-file to a temporary directory;
\item Generate a modified config file and replace the original
  config-file with it;
\item Try to restart Apache. If this fails, restore the original
  config-file, restart Apache and write a ``failure'' message.
\end{itemize}

@d add item in Apache site-config-file @{@%
tempdir=`mktemp -d -t flas.XXXXXX`
cp  $sitesdir/$siteconfigfile $tempdir/$siteconfigfile
@% gawk '@< awkscript @>'  <$tempdir/$siteconfigfile  >$tempdir/new.$siteconfigfile 
gawk '{ print }
      /Here the WSGIScriptAliases/ {
        printf( "    WSGIScriptAlias /%s %s/%s\n", demo_name, WSGI_DIR, wsgi_filename )
      }
      ' \
      demo_name=$demo_name WSGI_DIR=$WSGI_DIR  wsgi_filename=$wsgi_filename \
      <$tempdir/$siteconfigfile  >$tempdir/new.$siteconfigfile 
sudo cp $tempdir/new.$siteconfigfile   $sitesdir/$siteconfigfile
@| tempdir sitesdir siteconfigfile new.siteconfigfile @}


@d restart Apache @{@%
service apache2 reload
result=$?
if
   [ $result -gt 0 ]
then
  cp $tempdir/$siteconfigfile $sitesdir/$siteconfigfile
  service apache2 reload
  echo "Error. App not installed. Sorry." >&2
  exit $result
fi
rm -rf $tempdir
@| @}


\subsubsection{Set the parameters}
\label{sec:set-parameters}

As we have seen, a few parameters that have to be set are involved:

\begin{table}[hbtp]
  \begin{tabular}{lll}
    \textbf{Name}&\textbf{default}&\textbf{explanation} \\
    \texttt{virtenv} & unset \\
    \texttt{WSGI\_DIR} & \verb|/usr/local/share/demo_wsgi| & to store \texttt{wsgi} files \\
    \texttt{wsgi\_filename} & Name of python script & \textsc{wsgi} script. \\
    \texttt{demo\_dir} & unset &  Dir. of app. \\ 
    \texttt{demo\_filename\_without\_py} & unset/option & Path to app without suffix \\
    \texttt{sitesdir} & \verb|m4_sites_available| & Dir. for site config files \\
    \texttt{siteconfigfile} & \verb|m4_siteconfigfile| & Apache configuration file \\
    \texttt{demo\_name} & demo\_filename\_without\_py & suffix of \textsc{url} \\
  \end{tabular}
\end{table}

The user can set \verb|virtenv| with command-line option \verb|-v| and
she may specify a name of the demo (i.e. the suffix of the \textsc{url},
e.g. \verb|demo.cltl.nl/suffix|) that would otherwise be set to the name
of the file with the Python script of the app.

The macro below interprets the command-line options using the
\verb|getopts| mechanism (see
\href{https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash}{this tutorial in Stackoverflow}). 


@d get the options of add\_flask\_demo @{@%
unset demo_name
unset virtenv
while getopts :n:v:h opt
do
    case $opt in
	n)
	    demo_name=$OPTARG
	    ;;
	v)
	    virtenv="$(cd "$(dirname "$OPTARG")"; pwd)/$(basename "$OPTARG")"
	    ;;
	h)
	    HELP
	    exit 1
	    ;;
	\?)
	    echo "unknown option: $OPTARG."
	    HELP
	    exit 1
            ;;
    esac
done
shift $((OPTIND-1)) 
@| @}

The user must specify the path to the Python script with the app. So, let us abort execution and print a message when the user did not do this.

@d get location of the flask app or die @{@%
if
  [ -z ${1+x} ]
then
  HELP
  exit 1
fi
@| @}

If we have survived the above test, construct the full path to the
python script from the command-line argument \verb|\$1|. Check whether
the app really exists and abort execution otherwise.

@d get location of the flask app or die @{@%
demo_full_filename="$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
if
  [ ! -e $demo_full_filename ]
then
  echo Error: $demo_full_filename does not exist. >&2
  HELP
  exit 4
fi
@|demo_full_filename @}

Derive the name of the script with the app and the path to the
directory in which the script resides:

\begin{description}
\item[demo\_full\_filename:] Path to the python file of the app.
\item[demo\_filename:] Name of the python file itself.
\item[demo\_filename\_without\_py:]  
\end{description}

@d get location of the flask app or die @{@%
demo_filename=$(basename $demo_full_filename)
demo_filename_without_py=${demo_filename%.py}
demo_dir=$(dirname $demo_full_filename)
@|demo_filename demo_filename_without_py @}

Set the demo-name to the name of the Python script if the user did not
specify a demo-name.

@d get location of the flask app or die @{@%
if
    [ -z ${demo_name+x} ]
then
  demo_name=$demo_filename_without_py
fi
@| @}

Set the name and the path of the \verb|wsgi| script that invokes the
app and set the path to the Apache config-file:

@d set parameter values for add\_flask\_demo @{@%
WSGI_DIR=m4_default_WSGI_DIR
wsgi_filename=$demo_name.wsgi
sitesdir=m4_sites_available
siteconfigfile=m4_siteconfigfile
@|WSGI_DIR wsgi_filename sitesdir siteconfigfile @}

Finally, check whether an app with the chosen name does not yet exist.

@d set parameter values for add\_flask\_demo @{@%
grep -q "WSGIScriptAlias[[:space:]*]/$demo_name" /etc/apache2/sites-enabled/$siteconfigfile
if
  [ $? == 0 ]
then
  echo "Error: Demo $demo_name exists already" >&2
  exit 5
fi

@| @}

\subsubsection{Putting everything together}
\label{sec:the-add-flask-demo-script}

Finally, produce the script:

@o m4_bindir/add_flask_demo @{@%
#!/bin/bash
# add_flask_demo -- publish a flask demo.
# Argument: Python-file with app
# Options: -n Alternative name for demo
#          -v path to virtual environment.
#Set Script Name variable
SCRIPT=`basename ${BASH_SOURCE[0]}`
@< pretty fonts for help function @>
@< help function of add\_flask\_demo @>
@< get the options of add\_flask\_demo @>
@< get location of the flask app or die @>
@< set parameter values for add\_flask\_demo @>

#
# Break if a demo with the same name exists already.
#

#
# Generate wsgi file
#
rm -f $WSGI_DIR/$wsgi_filename
@< build the wsgi file @>
@% if
@%     [ ! -z ${virtenv+x} ]
@% then
@%   virtenv_full="$(cd "$(dirname "$virtenv")"; pwd)/$(basename "$virtenv")"
@%   cat >$WSGI_DIR/$wsgi_filename <<EOF
@% activate_this = '$virtenv_full/bin/activate_this.py'
@% with open(activate_this) as file_:
@%     exec(file_.read(), dict(__file__=activate_this))
@% EOF
@% fi
@% cat >>$WSGI_DIR/$wsgi_filename <<EOF
@% import sys
@% sys.path.insert(0, '$demo_dir')
@% from $demo_filename_without_py import app as application
@% EOF
@< add item in Apache site-config-file @>
@< restart Apache @>

@% #
@% # Add item in Apache site-config-file
@% #
@% tempdir=`mktemp -d -t flas.XXXXXX`
@% cat >$tempdir/awkscript.awk <<EOF
@% { print }
@% /Here the WSGIScriptAliases/ {
@%   printf( "    WSGIScriptAlias /$demo_name $WSGI_DIR/$wsgi_filename\n" )
@% }
@% EOF
@% cp  $sitesdir/$siteconfigfile $tempdir/$siteconfigfile
@% # cat $tempdir/$siteconfigfile |  gawk -f $tempdir/awkscript.awk >$sitesdir/$siteconfigfile
@% gawk -f $tempdir/awkscript.awk < $tempdir/$siteconfigfile  >$tempdir/new.$siteconfigfile 
@% sudo cp $tempdir/new.$siteconfigfile   $sitesdir/$siteconfigfile 
@% #
@% # Reload Apache and clean up
@% #
@% service apache2 reload
@% result=$?
@% if
@%    [ $result -gt 0 ]
@% then
@% cp $tempdir/$siteconfigfile $sitesdir/$siteconfigfile
@% service apache2 reload
@% echo "Error. App not installed. Sorry." >&2
@% exit $result
@% fi
@% rm -rf $tempdir

@| @}


\section{Miscellaneous}
\label{sec:misc}

\subsection{Fonts}
\label{sec:fonts}

The help function uses pretty fonts. I forgot where I stole these font declarations.

@d pretty fonts for help function @{@%
#Set fonts for Help.
NORM=`tput sgr0`
BOLD=`tput bold`
REV=`tput smso`
UL=`tput smul`
@| @}


\section{Indexes}
\label{sec:indexes}

\subsection{Filenames}
\label{sec:filenames}

@f

\subsection{Macro's}
\label{sec:macros}

@m

\subsection{Variables}
\label{sec:veriables}

@u

@% \subsection{General index}
@% \label{sec:genindex}

\printindex

\end{document}
