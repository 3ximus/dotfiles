import IPython.terminal.prompts as prompts
from prompt_toolkit.application import get_app
from prompt_toolkit.key_binding.vi_state import InputMode
from pygments.token import Token
from warnings import filterwarnings


import sys, os
sys.path.append(os.path.expanduser('~/.ipython/profile_default/'))

config = get_config()  # type: ignore # noqa: E0602

class Prompt(prompts.Prompts):
	_continuation: str = "… "

	def in_prompt_tokens(self):
		venv_prompt = []
		if get_app().vi_state.input_mode == InputMode.INSERT:
			prompt_token = prompts.Token.InsertPrompt
			num_token = prompts.Token.InsertPromptNum
			if 'VIRTUAL_ENV' in os.environ:
				venv_prompt = [
					(prompt_token, ' ('),
					(num_token, str(os.environ.get('VIRTUAL_ENV_PROMPT'))),
					(prompt_token, ')'),
				]
		else:
			prompt_token = prompts.Token.NavPrompt
			num_token = prompts.Token.NavPromptNum
			if 'VIRTUAL_ENV' in os.environ:
				venv_prompt = [
					(prompt_token, ' ('),
					(num_token, str(os.environ.get('VIRTUAL_ENV_PROMPT'))),
					(prompt_token, ')'),
				]
		return [
			(prompt_token, '['),
			(num_token, str(self.shell.execution_count)),
			(prompt_token, ']'),
			*venv_prompt,
			(prompt_token, '>> '),
		]

	def continuation_prompt_tokens( self, width = None):
		"""Return continuation prompt."""
		if get_app().vi_state.input_mode == InputMode.INSERT:
			prompt_token = prompts.Token.InsertPrompt
		else:
			prompt_token = prompts.Token.NavPrompt
		return [(prompt_token, " " * (self._width() - 2) + self._continuation)]

	def out_prompt_tokens(self):
		"""Return out prompt."""
		return []


config.TerminalIPythonApp.display_banner = False
config.TerminalInteractiveShell.confirm_exit = False
config.TerminalInteractiveShell.editing_mode = "vi"
config.TerminalInteractiveShell.true_color = True
config.TerminalInteractiveShell.separate_in = ''
config.TerminalInteractiveShell.prompts_class = Prompt
config.TerminalInteractiveShell.colors = "gruvbox-dark"
config.TerminalInteractiveShell.highlighting_style_overrides = {
	Token.InsertPrompt: f"#83a598 bold",
	Token.NavPrompt: f"#fe8019 bold",
	Token.InsertPromptNum: f"#b16286 bold",
	Token.NavPromptNum: f"#458588 bold",
}
filterwarnings("ignore", "Attempting to work in a virtualenv")
