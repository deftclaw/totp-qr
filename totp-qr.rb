#!/usr/bin/env ruby
# frozen_string_literal: true

require 'auth'
require 'rqrcode'
require 'highline/import'

@tleaf = `mktemp`.chomp!
@link  = "#{ENV['HOME']}/.config/otp.yml"
@rute  = "#{ENV['TMP']}/totp"

@ld = {
  link: ->(l) { system("ln -sf #{@rute}/#{l} #{@link}") },
  list: -> { Dir.new('.').children.select{|l| l.end_with? '.yml'} },
  message: ->(p) { "otpauth://totp/#{p[:email]}?issuer=#{p[:issuer]}&secret=#{p[:secret]}" },
  props: ->(s) {{ email: ask('Email/Username: ').gsub!(/@/, '%40'), issuer: ask('Company/Account Issuer: '), secret: s }},
  qr: ->(msg) { RQRCode::QRCode.new(msg).as_png(size: 150) },
  secret: -> { temp = Auth::OTP.new ; temp::to_yaml.split(/\n/)[-1].split(/: /)[-1] }
}

def share_totp(leaf)
  puts "Reading: #{leaf}"
  @ld[:link].call(leaf)

  File.write(
    @tleaf,
    @ld[:qr].call(
      @ld[:message].call(
        @ld[:props].call(
          @ld[:secret].call
    ))),
    mode: 'wb'
  )

  begin
    `feh #{@tleaf}`
  rescue Interrupt => error
    puts('User Cancelled')
  ensure
    File.delete(@tleaf)
  end
end

def loop_totps(list)
  list.each do |leaf|
    share_totp(leaf)
  end
end
