module gitsummary;

import std.stdio;
import std.getopt;
import std.process;
import std.format;
import std.string : strip;
import std.file;

// git log --all --graph --oneline
// git log --since="7 days ago" --date=relative --format="..."
// format: %ar: %s%n

// errorcode 128: not a git repo

alias spawnShell shell;

version (Windows)
{
	enum NULL_REDIRECT = " > nul 2>&1";
}
else
{
    enum NULL_REDIRECT = " > /dev/null 2>&1";
}

enum COMMAND_GIT_VERSION = "git --version";

struct Settings
{
    /// For dirEntries.
    string baseDir = ".";
    
    /// 
    string gitdate = "relative"; // --date
    /// 
    string gitsince = "1 month ago"; // --since
    /// 
    string gitformat = "- %ar: %s"; // --format
    /// Show warnings.
    bool showWarnings;
    /// 
    bool showVersion;
}

void quit(int code)
{
    import core.stdc.stdlib : exit;
    exit(code);
}
void halt(string msg, int code)
{
    stderr.writeln("error: ", msg);
    quit(code);
}
void halt(Exception ex, int code)
{
    debug stderr.writeln("Trace:\n", ex.info);
    halt(ex.msg, code);
}
void warn(A...)(A msgs)
{
    stderr.writeln("warning: ", msgs);
}
void info(A...)(A msgs)
{
    writeln("info: ", msgs);
}

void main(string[] args)
{
    Settings settings;
    
    GetoptResult optres = void;
    try
    {
        optres = getopt(args,
            "D|directory", `Base directory to traverse. default="`~settings.baseDir~`"`, &settings.baseDir,
            "W|warnings", `Show warnings.`, &settings.showWarnings,
            "d|git-date", `Git date format. default="`~settings.gitdate~`"`, &settings.gitdate,
            "s|git-since", `Git since timestamp. default="`~settings.gitsince~`"`, &settings.gitsince,
            "f|git-format", `Git commit format. default="`~settings.gitformat~`"`, &settings.gitformat,
            "version", "Show version page and quit.", &settings.showVersion,
        );
    }
    catch (Exception ex)
    {
        halt(ex, 1);
    }
    
    if (optres.helpWanted)
    {
        defaultGetoptPrinter("Git summarization tool.", optres.options);
        quit(0);
    }
    
    if (settings.showVersion)
    {
        write(
        "gitsummary (compiled: "~__TIMESTAMP__~")\n"~
        "License: 0-BSD\n"~
        "Homepage: https://github.com/dd86k/gitsummary\n"
        );
        quit(0);
    }
    
    string gitVer = void;
    try
    {
        // May throw ProcessException if not found
        scope git = execute(["git", "--version"]);
        
        if (git.status)
            throw new Exception("git --version returned non-zero status code.");
        
        //gitVer = strip(git.output);
    }
    catch (Exception ex)
    {
        halt(ex, 2);
    }
    
    //info("Using ", gitVer);
    
    size_t startp = settings.baseDir.length + 1; // +separator
    foreach (DirEntry entry; dirEntries(settings.baseDir, SpanMode.shallow, false))
    {
        if (entry.isDir == false)
            continue;
        
        scope command = [
            "git", "-C", entry.name, "log",
            format!`--date=%s`(settings.gitdate),
            format!`--format=%s`(settings.gitformat),
            format!`--since=%s`(settings.gitsince),
        ];
        
        //writeln("command: ", command);
        
        auto git = execute(command);
        
        if (git.status)
        {
            if (settings.showWarnings) warn("git error: ", git.output);
            continue;
        }
        if (git.output.length == 0)
        {
            continue;
        }
        
        // Turn "basedir/folder" to "folder" for printing purposes
        writeln("# ", entry.name[startp..$], ":");
        writeln(git.output);
    }
}
