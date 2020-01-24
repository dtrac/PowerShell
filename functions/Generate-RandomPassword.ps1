function _GenerateRandomPassword {
  <#
    .SYNOPSIS
      Generates random password which meet windows complexity requirements.
    .DESCRIPTION
      This function generates a password to be set on built-in account before
      it is disabled.
    .OUTPUTS
      Returns String
    .EXAMPLE
      _GeneratePassword
  #>

  # Define length of the password. Maximum and minimum.
  [int] $pass_min = 12
  [int] $pass_max = 35
  [string] $random_password = $null

  # Random password length should help prevent masking attacks.
  $password_length = Get-Random -Minimum $pass_min -Maximum $pass_max

  # Choose a set of ASCII characters we'll use to generate new passwords from.
  $ascii_char_set = $null
  for ($x=33; $x -le 126; $x++) {
    $ascii_char_set+=,[char][byte]$x
  }

  # Generate random set of characters.
  for ($loop=1; $loop -le $password_length; $loop++) {
    $random_password += ($ascii_char_set | Get-Random)
  }
  return $random_password
}
