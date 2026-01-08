#!/usr/bin/env bash

_Main()
{
  local cmd="ln -s ~/sandbox/github/kapresoft/wow/LibPrettyPrint/Libs/LibPrettyPrint ./Gears/ThirdParty/Libs/."
  echo "Executing: ${cmd}"
  eval "${cmd}" && echo "Execution Complete: ${cmd}"
}

_Main
