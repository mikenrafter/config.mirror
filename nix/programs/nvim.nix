##bash ~/.nix/build.sh
{ u1, s1 }:
u1.neovim.override {
	configure = {
		packages.myPlugins = with u1.vimPlugins; {
			start = [

				vim-nix


#				barbar-nvim
				nvim-web-devicons
#				nvim-tree-lua

				#nvim-code-action-menu
				nvim-lspconfig
#					s1.haskell-language-server


				nvim-cmp
				cmp-nvim-lsp
				cmp-treesitter
				cmp-spell
				cmp-emoji

				ultisnips
				vim-snippets

#				u1.python38Packages.pylint

				coc-nvim
				coc-pairs
				coc-smartf
				coc-snippets
				coc-prettier
				coc-markdownlint
				coc-java
				coc-python
				coc-fzf
				coc-git
#				coc-explorer


				(nvim-treesitter.withPlugins (plugins:
					u1.tree-sitter.allGrammars			# might as well
				))
				nvim-colorizer-lua
			];
			opt = [];
		};
		customRC = (builtins.readFile ../.vimrc);
	};
}
