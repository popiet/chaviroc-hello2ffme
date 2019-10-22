package Chaviroc::Hello2Ffme;

use Text::CSV_XS;

require Exporter;
our @ISA = qw< Exporter >;
our @EXPORT_OK = qw< data conf value action type assurance ski slackline trail vtt >;

sub data {
    my ($row, $head) = @_;
    return { map { $head->[$_] => $row->[$_] } 0 .. $#$head };
}

sub conf {
    my $file = shift;

    open my $in, '<', $file
        or die "pb open $file: $!";

    my $parser = Text::CSV_XS->new({
        allow_loose_quotes => 1,
        binary => 1,
        sep_char => ';',
    });

    my $head = $parser->getline($in);

    my @fields;
    
    while (my $row = $parser->getline($in)) {
        push @fields, $row
            if $row->[0];
    }

    return @fields;
}

sub value {
    my ($data, $field) = @_;
    
    my $ffme = $field->[0];
    my $hello = $field->[1];

    my $value;

    # call fct ?
    if ($hello =~ /^fct:(.*)/) {
        my $fct = \&{"$1"};
        my @args = map { $data->{ $field->[$_] } // '' } 2 .. $#$field;
        $value = $fct->(@args);
    } else {
        $value = join ' ', map { $data->{ $field->[$_] } // '' } 1 .. $#$field;
    }
    
    return $value;            
}

sub action {
    my $num = shift;
    return $num ? 'R' : 'C';
}

sub type {
    my $formule = shift;

    return 'J' if $formule =~ /jeune/i;
    return 'A' if $formule =~ /adulte/i;
    return 'F' if $formule =~ /famille/i;
}

sub assurance {
    my $formule = shift;

    return 'B++' if $formule =~ /Assurance Base \+\+/i;
    return 'B+'  if $formule =~ /Assurance Base \+/i;
    return 'B'   if $formule =~ /Assurance Base/;
    
    return 'RC';
}

sub ski {
}

sub slackline {
}

sub trail {
}

sub vtt {
}

1;
