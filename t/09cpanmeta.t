#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use UNIVERSAL::require;

plan(skip_all => 'Test::CPAN::Meta required')
    unless Test::CPAN::Meta->require();

Test::CPAN::Meta->import();

meta_yaml_ok();
