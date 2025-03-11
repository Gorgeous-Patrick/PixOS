{
  config,
  pkgs,
  lib,
  ...
}:
{
  keymaps = [
    {
      action = "<Esc>";
      key = "jk";
      mode = [ "i" ];
    }
    {
      action = "<cmd>NvimTreeToggle<CR>";
      key = "<C-n>";
      mode = [
        "n"
        "v"
      ];
      options = {
        desc = "Toggle Tree View.";
      };
    }
    {
      action = "^";
      key = "<S-h>";
      mode = [
        "n"
        "v"
      ];
    }
    {
      action = "$";
      key = "<S-l>";
      mode = [
        "n"
        "v"
      ];
    }
    {
      action = "<cmd>ToggleTerm direction=float<CR>";
      key = "<C-CR>";
      mode = [
        "n"
        "t"
      ];
      options = {
        desc = "Toggle terminal";
      };
    }
    {
      action = "<cmd>Telescope find_files<cr>";
      key = "<leader>ff";
      mode = [
        "n"
        "t"
      ];
      options = {
        desc = "Find Files";
      };
    }
    {
      action = "<cmd>LazyGit<cr>";
      key = "<leader>gg";
      mode = [
        "n"
        "t"
        "v"
      ];
      options = {
        desc = "Git";
      };
    }
    {
      action = "<cmd>Trouble diagnostics toggle<cr>";
      key = "<leader>tt";
      mode = [
        "n"
        "v"
      ];
      options = {
        desc = "Toggle Trouble";
      };
    }
    {
      action = "<cmd>Telescope find_files<cr>";
      key = "<leader>ff";
      mode = [
        "n"
        "v"
        "t"
      ];
      options = {
        desc = "Find Files";
      };
    }
    {
      action = "<cmd>Telescope live_grep<cr>";
      key = "<leader>fg";
      mode = [
        "n"
        "v"
        "t"
      ];
      options = {
        desc = "Live Grep";
      };
    }
    {
      action = "<cmd>Telescope buffers<cr>";
      key = "<leader>fb";
      mode = [
        "n"
        "v"
        "t"
      ];
      options = {
        desc = "Buffers";
      };
    }
    {
      action = "<cmd>Telescope help_tags<cr>";
      key = "<leader>fh";
      mode = [
        "n"
        "v"
        "t"
      ];
      options = {
        desc = "Help Tags";
      };
    }
    {

      key = "s";

      action.__raw = ''

        function()

        require'flash'.jump({

        })

        end

      '';

      options.remap = true;

    }

    {

      key = "<c-s>";

      action.__raw = ''

        function()

        require'flash'.toggle({

        })

        end

      '';

      options.remap = true;

    }

  ];
}
