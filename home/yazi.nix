{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # Use a function so quitting Yazi can change the parent shell's directory.
    shellWrapperName = "y";

    settings = {
      mgr = {
        ratio = [
          1
          3
          4
        ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_dir_first = true;
        show_hidden = true;
        show_symlink = true;
        linemode = "size";
        scrolloff = 5;
      };

      preview = {
        wrap = "yes";
        tab_size = 2;
        max_width = 1600;
        max_height = 1200;
      };

      opener.edit = [
        {
          run = "nvim %s";
          block = true;
          desc = "Edit in Neovim";
          for = "unix";
        }
      ];
    };

    keymap = {
      mgr.prepend_keymap = [
        {
          on = "!";
          run = ''shell "$SHELL" --block'';
          desc = "Open shell here (exit to return)";
        }
        {
          on = [
            "g"
            "s"
          ];
          run = "cd ~/Space";
          desc = "Go to projects";
        }
        {
          on = "<C-y>";
          run = "copy path";
          desc = "Copy file path to clipboard";
        }
        {
          on = "<F2>";
          run = "rename --cursor=before_ext";
          desc = "Rename file";
        }
      ];

      input.prepend_keymap = [
        {
          on = "<Esc>";
          run = "close";
          desc = "Cancel input";
        }
      ];
    };
  };

  # Track visited shell directories for Yazi's built-in zoxide jump.
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
