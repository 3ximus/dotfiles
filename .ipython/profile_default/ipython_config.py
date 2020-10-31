from typing import List, Optional, Tuple

import IPython.terminal.prompts as prompts
from prompt_toolkit.application import get_app
from prompt_toolkit.key_binding.vi_state import InputMode
from pygments.token import _TokenType, Token

from dataclasses import dataclass
from typing import Any, Dict

import sys, os
sys.path.append(os.path.expanduser('~/.ipython/profile_default/'))
from gruvbox import Color, GruvboxStyle

config = get_config()  # type: ignore # noqa: E0602

class Prompt(prompts.Prompts):
	"""Custom IPython prompt."""

	_before: str = "["
	_after: str = "] >> "
	_continuation: str = "… "

	def in_prompt_tokens(self):
		"""Return in prompt."""
		if get_app().vi_state.input_mode == InputMode.INSERT:
			prompt_token = prompts.Token.InsertPrompt
			num_token = prompts.Token.InsertPromptNum
		else:
			prompt_token = prompts.Token.NavPrompt
			num_token = prompts.Token.NavPromptNum

		return [(prompt_token, '>>> '),]
		# return [
		#	  (prompt_token, self._before),
		#	  (num_token, str(self.shell.execution_count)),
		#	  (prompt_token, self._after),
		# ]

	def continuation_prompt_tokens( self, width = None):
		"""Return continuation prompt."""
		if get_app().vi_state.input_mode == InputMode.INSERT:
			prompt_token = prompts.Token.InsertPrompt
		else:
			prompt_token = prompts.Token.NavPrompt

		return [(prompt_token, " " * (self._width()))]
		# return [(prompt_token, " " * (self._width() - 2) + self._continuation)]

	def out_prompt_tokens(self):
		"""Return out prompt."""
		return []


config.TerminalIPythonApp.display_banner = False
config.TerminalInteractiveShell.confirm_exit = False
config.TerminalInteractiveShell.editing_mode = "vi"
config.TerminalInteractiveShell.true_color = True
config.TerminalInteractiveShell.separate_in = ''
config.TerminalInteractiveShell.prompts_class = Prompt
config.TerminalInteractiveShell.highlighting_style = GruvboxStyle
config.TerminalInteractiveShell.highlighting_style_overrides = {
	Token.InsertPrompt: f"{Color.bright_blue} bold",
	Token.NavPrompt: f"{Color.bright_orange} bold",
	Token.InsertPromptNum: f"{Color.neutral_purple} bold",
	Token.NavPromptNum: f"{Color.neutral_blue} bold",
}
