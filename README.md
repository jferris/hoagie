# hoagie: a delicious way to organize programs

Hoagie is a model for setting up shell programs that use hoagiecommands, like `git` or `rbenv` using bash. Making a hoagie does not require you to write shell scripts in bash, you can write hoagiecommands in any scripting language you prefer.

A hoagie program is run at the command line using this style:

    $ [name of program] [hoagiecommand] [(args)]

Here's some quick examples:

    $ rbenv                    # prints out usage and hoagiecommands
    $ rbenv versions           # runs the "versions" hoagiecommand
    $ rbenv shell 1.9.3-p194   # runs the "shell" hoagiecommand, passing "1.9.3-p194" as an argument

Each hoagiecommand maps to a separate, standalone executable program. Hoagie programs are laid out like so:

    .
    ├── bin               # contains the main executable for your program
    ├── completions       # (optional) bash/zsh completions
    ├── libexec           # where the hoagiecommand executables are
    └── share             # static data storage

## Hoagiecommands

Each hoagiecommand executable does not necessarily need to be in bash. It can be any program, shell script, or even a symlink. It just needs to run.

Here's an example of adding a new hoagiecommand. Let's say your hoagie is named `rush`. Run:

    touch libexec/rush-who
    chmod a+x libexec/rush-who

Now open up your editor, and dump in:

``` bash
#!/usr/bin/env bash
set -e

who
```

Of course, this is a simple example...but now `rush who` should work!

    $ rush who
    qrush     console  Sep 14 17:15 

You can run *any* executable in the `libexec` directly, as long as it follows the `NAME-SUBCOMMAND` convention. Try out a Ruby script or your favorite language!

## What's on your hoagie

You get a few commands that come with your hoagie:

* `commands`: Prints out every hoagiecommand available
* `completions`: Helps kick off hoagiecommand autocompletion.
* `help`: Document how to use each hoagiecommand
* `init`: Shows how to load your hoagie with autocompletions, based on your shell.
* `shell`: Helps with calling hoagiecommands that might be named the same as builtin/executables.

If you ever need to reference files inside of your hoagie's installation, say to access a file in the `share` directory, your hoagie exposes the directory path in the environment, based on your hoagie name. For a hoagie named `rush`, the variable name will be `_RUSH_ROOT`.

Here's an example hoagiecommand you could drop into your `libexec` directory to show this in action: (make sure to correct the name!)

``` bash
#!/usr/bin/env bash
set -e

echo $_RUSH_ROOT
```

You can also use this environment variable to call other commands inside of your `libexec` directly. Composition of this type very much encourages reuse of small scripts, and keeps scripts doing *one* thing simply.

## Self-documenting hoagiecommands

Each hoagiecommand can opt into self-documentation, which allows the hoagiecommand to provide information when `hoagie` and `hoagie help [SUBCOMMAND]` is run.

This is all done by adding a few magic comments. Here's an example from `rush who` (also see `hoagie commands` for another example):

``` bash
#!/usr/bin/env bash
# Usage: hoagie who
# Summary: Check who's logged in
# Help: This will print out when you run `hoagie help who`.
# You can have multiple lines even!
#
#    Show off an example indented
#
# And maybe start off another one?

set -e

who
```

Now, when you run `hoagie`, the "Summary" magic comment will now show up:

    usage: hoagie <command> [<args>]

    Some useful hoagie commands are:
       commands               List all hoagie commands
       who                    Check who's logged in

And running `hoagie help who` will show the "Usage" magic comment, and then the "Help" comment block:

    Usage: hoagie who

    This will print out when you run `hoagie help who`.
    You can have multiple lines even!

       Show off an example indented

    And maybe start off another one?

That's not all you get by convention with hoagie...

## Autocompletion

Your hoagie loves autocompletion. It's the mustard, mayo, or whatever topping you'd like that day for your commands. Just like real toppings, you have to opt into them! Hoagie provides two kinds of autocompletion:

1. Automatic autocompletion to find hoagiecommands (What can this hoagie do?)
2. Opt-in autocompletion of potential arguments for your hoagiecommands (What can this hoagiecommand do?)

Opting into autocompletion of hoagiecommands requires that you add a magic comment, and then support parsing of a flag: `--complete`. Here's an example from rbenv, namely `rbenv whence`:

``` bash
#!/usr/bin/env bash
set -e
[ -n "$RBENV_DEBUG" ] && set -x

# Provide rbenv completions
if [ "$1" = "--complete" ]; then
  echo --path
  exec rbenv shims --short
fi

# lots more bash...
```

Passing the `--complete` flag to this hoagiecommand short circuits the real command, and then runs another hoagiecommand instead. The output from your hoagiecommand's `--complete` run is sent to your shell's autocompletion handler for you, and you don't ever have to once worry about how any of that works!

Run the `init` hoagiecommand after you've prepared your hoagie to get your hoagie loading automatically in your shell.

## Shortcuts

Creating shortcuts for commands is easy, just symlink the shorter version you'd like to run inside of your `libexec` directory.

Let's say we want to shorten up our `rush who` to `rush w`. Just make a symlink!

    cd libexec
    ln -s rush-who rush-w

Now, `rush w` should run `libexec/rush-who`, and save you mere milliseconds of typing every day!

## Prepare your hoagie

Clone this repo:

    git clone git://github.com/37signals/hoagie.git [name of your hoagie]
    cd [name of your hoagie]
    ./prepare.sh [name of your hoagie]

The prepare script will run you through the steps for making your own hoagie.

## License

MIT. See `LICENSE`.
