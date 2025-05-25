{ tools, lib, ... }:
{
  config = {
    name = "detect-aws-credentials";
    description = "Detect AWS credentials from the AWS cli credentials file.";
    package = tools.pre-commit-hooks;
    entry = "${tools.pre-commit-hooks}/bin/detect-aws-credentials --allow-missing-credentials";
    types = [ "text" ];
  };
}