#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rqrcode'
require 'highline/import'

EMAIL = HighLine.new.ask("Email: ").gsub(/@/, '%40')
ISSUER = HighLine.new.ask("Account with? (eg. Amazon, Google, GitHub...): ")
SECRET = ask("TOTP Secret: ") { |inp| inp.echo = '*' }

message = "otpauth://totp/#{EMAIL}?issuer = #{ISSUER}&secret = #{SECRET}"
tleaf   = `mktemp`.chomp!

File.write(tleaf, RQRCode::QRCode.new(message).as_png(size: 300), mode: 'wb')
begin
  `feh #{tleaf}`
rescue => Interrupt
  p 'User Cancelled'
ensure
  File.delete(tleaf)
end
