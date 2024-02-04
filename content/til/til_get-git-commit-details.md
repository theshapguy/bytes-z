+++

title = "Get Git Details From Elixir"
date = "2024-01-20"
draft = false

[taxonomies]
tags = ["elixir", "git", "til"]
categories = ["Today I Learned", "Elixir"]


[extra]
lang = "en"
toc = false

+++

The following snippet allows you to extract the SHA1 of the git commit from within elixir. It is useful to attach the SHA1 to your release or code so that if therea are any issues you can quickly checkout the commit and look into it.


You can also get the branch name if required.

```elixir
  def git_commit_sha() do
    System.cmd("git", ["rev-parse", "--short", "HEAD"])
    |> elem(0)
    |> String.trim()
  end

  def git_branch_name() do
    System.cmd("git", ["rev-parse", "--abbrev-ref", "HEAD"])
    |> elem(0)
    |> String.trim()
  end
```