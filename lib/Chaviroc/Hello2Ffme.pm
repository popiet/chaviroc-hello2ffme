package Chaviroc::Hello2Ffme;

use Text::CSV_XS;

require Exporter;
our @ISA = qw< Exporter >;
our @EXPORT_OK = qw< data conf value action type assurance ski slackline trail vtt code_pays conf_pays >;

sub data {
    my ($row, $head) = @_;
    return { map { $head->[$_] => $row->[$_] } 0 .. $#$head };
}

my $parser = Text::CSV_XS->new({
    allow_loose_quotes => 1,
    binary => 1,
    sep_char => ';',
});

sub conf {
    my $file = shift;

    open my $in, '<', $file
        or die "pb open $file: $!";

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
        my $fn  = $1;
        my $fct = \&{"$fn"};
      
        my @args = map { $data->{ $field->[$_] } // '' } 2 .. $#$field;
        eval { $value = $fct->(@args) };
      
        # expliciter l'erreur
        die "ligne: [" . join(';', @$field) . "]\n"
            . "[$fn] n'est pas une fonction de " . __PACKAGE__ . "\n"
            if $@ =~ /^Undefined subroutine/;
        die $@ if $@;
    } else {
        $value = '';
        for (1 .. $#$field) {
            $value .= ' ' 
                if $value;
            
            # vérification que le champ existe dans le fichier d'entrée
            die "ligne: [" . join(';', @$field) . "]\n"
                . "[$field->[$_]] n'est pas un champ du fichier d'entrée\n"
                if $field->[$_] && ! exists $data->{ $field->[$_] };

            $value .= $data->{ $field->[$_] } // '';
        }
    }
    
    return $value;            
}

sub action {
    my $num = shift;
    return $num ? 'R' : 'C';
}

my $codes;

sub conf_pays {
    my $file = shift;

    open my $in, '<', $file
        or die "pb open < $file: $!";

    $parser->getline($in);
    while (my $row = $parser->getline($in)) {
        $codes->{$row->[0]} = $row->[1];
    }
}

sub code_pays {
    my $pays = shift;    

    $codes //= conf_pays;

    # match direct
    return $codes->{$pays} if $codes->{$pays};

    # on essaie sans la casse
    for my $key (keys %$codes) {
        return $codes->{$key} if lc $key eq lc $pays;
    }

    # FR par défaut
    return 'FR';
}

sub sante {
    return shift ? 'OUI' : 'NON';
}

sub alpinisme {
    return 'NON';
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
