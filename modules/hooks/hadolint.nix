{ config, tools, lib, ... }:
{
  config = {
    package = tools.hadolint;
    entry = "${config.package}/bin/hadolint";
    files = "Dockerfile$";
  };
}
