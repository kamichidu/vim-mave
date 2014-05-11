#!/usr/bin/env perl

package ArchetypeHandler;

use utf8;
use strict;
use warnings;
use base qw/XML::SAX::Base/;

sub new
{
    my ($class)= @_;

    bless {
        current    => {},
        key        => '',
        archetypes => [],
    }, $class;
}

sub start_element
{
    my ($self, $el)= @_;

    # $el has Prefix'' LocalName'' Attrubutes{} Name'' NamespaceURI''
    if($el->{Name} eq 'archetype-catalog')
    {
    }
    elsif($el->{Name} eq 'archetypes')
    {
    }
    elsif($el->{Name} eq 'archetype')
    {
        $self->{current}= {};
    }
    elsif($el->{Name} eq 'groupId')
    {
        $self->{key}= 'group_id';
    }
    elsif($el->{Name} eq 'artifactId')
    {
        $self->{key}= 'artifact_id';
    }
    elsif($el->{Name} eq 'version')
    {
        $self->{key}= 'version';
    }
    elsif($el->{Name} eq 'description')
    {
        $self->{key}= 'description';
    }
    else
    {
        delete $self->{current};
        delete $self->{key};
    }
}

sub characters
{
    my ($self, $data)= @_;

    if($self->{key})
    {
        $self->{current}{$self->{key}}= $data->{Data};

        delete $self->{key};
    }
}

sub end_element
{
    my ($self, $el)= @_;

    if($el->{Name} eq 'archetype')
    {
        push $self->{archetypes}, $self->{current};
    }
}

package main;

use utf8;
use strict;
use warnings;
use Carp;
use XML::SAX::ParserFactory;
use JSON;

$XML::SAX::ParserPackage= 'XML::LibXML::SAX';

my $handler= ArchetypeHandler->new;
my $parser= XML::SAX::ParserFactory->parser(
    Handler => $handler,
);

$parser->parse_uri('http://repo1.maven.org/maven2/archetype-catalog.xml');

my $result= to_json $handler->{archetypes}, {ascii => 1, utf8 => 1, pretty => 1};
print $result;

1;
