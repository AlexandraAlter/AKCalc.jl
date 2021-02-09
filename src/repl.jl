module REPLMode

#using Markdown, UUIDs, Dates

import REPL
import REPL: LineEdit, REPLCompletions

import AKCalc

struct Option
end

struct Arg
end

struct Command
end

struct State
  gamedata::Union{AKCalc.GameData.Source, Nothing}
  playerdata::Union{AKCalc.PlayerData.Source, Nothing}
  statsdata::Union{AKCalc.StatsData.Source, Nothing}
end
State() = State(nothing, nothing, nothing)

function do_cmd(repl::REPL.AbstractREPL, input::String; do_rethrow=false)
  @assert false "Unimplemented"
end

function do_cmd!(repl::REPL.AbstractREPL, input::String; do_rethrow=false)
  @assert false "Unimplemented"
end

# Provide a string macro ak"cmd" that can be used in the same way
# as the REPLMode `ak> cmd`. Useful for testing and in environments
# where we do not have a REPL, e.g. IJulia.
struct MiniREPL <: REPL.AbstractREPL
  display::TextDisplay
  t::REPL.Terminals.TTYTerminal
end
function MiniREPL()
  env = get(ENV, "TERM", Sys.iswindows() ? "" : "dumb")
  MiniREPL(TextDisplay(stdout), REPL.Terminals.TTYTerminal(env, stdin, stdout, stderr))
end
REPL.REPLDisplay(repl::MiniREPL) = repl.display

const minirepl = Ref{MiniREPL}()

__init__() = minirepl[] = MiniREPL()

macro ak_str(str::String)
  :($(do_cmd)(minirepl[], $str; do_rethrow=true))
end

akstr(str::String) = do_cmd(minirepl[], str; do_rethrow=true)

function promptf()
  return "ak> "
end

function create_mode(repl::REPL.AbstractREPL, main::LineEdit.Prompt)
  ak_mode = LineEdit.Prompt(promptf;
    prompt_prefix = repl.options.hascolor ? Base.text_colors[:light_blue] : "",
    prompt_suffix = "",
    # complete = PkgCompletionProvider(),
    sticky = true)

  ak_mode.repl = repl
  hp = main.hist
  hp.mode_mapping[:ak] = ak_mode
  ak_mode.hist = hp

  search_prompt, skeymap = LineEdit.setup_search_keymap(hp)
  prefix_prompt, prefix_keymap = LineEdit.setup_prefix_keymap(hp, ak_mode)

  ak_mode.on_done = (s, buf, ok) -> begin
    ok || return REPL.transition(s, :abort)
    input = String(take!(buf))
    REPL.reset(repl)
    do_cmd(repl, input, do_rethrow=true)
    REPL.prepare_next(repl)
    REPL.reset_state(s)
    s.current_mode.sticky || REPL.transition(s, main)
  end

  mk = REPL.mode_keymap(main)

  b = Dict{Any,Any}[
    skeymap, mk, prefix_keymap, LineEdit.history_keymap,
    LineEdit.default_keymap, LineEdit.escape_defaults
  ]
  ak_mode.keymap_dict = LineEdit.keymap(b)

  return ak_mode
end

function repl_init(repl::REPL.AbstractREPL)
  main_mode = repl.interface.modes[1]
  ak_mode = create_mode(repl, main_mode)
  push!(repl.interface.modes, ak_mode)
  keymap = Dict{Any,Any}(
    '#' => function (s,args...)
      if isempty(s) || position(LineEdit.buffer(s)) == 0
        buf = copy(LineEdit.buffer(s))
        LineEdit.transition(s, ak_mode) do
          LineEdit.state(s, ak_mode).input_buffer = buf
        end
      else
        LineEdit.edit_insert(s, '#')
      end
    end
  )
  main_mode.keymap_dict = LineEdit.keymap_merge(main_mode.keymap_dict, keymap)
  return
end

end
