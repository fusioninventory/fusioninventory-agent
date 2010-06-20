#!/usr/bin/perl

use Test::More;

eval {
    require Test::Distribution;
    Test::Distribution->import(only => 'use');
};
plan(skip_all => 'Test::Distribution not installed; skipping' ) if $@;
