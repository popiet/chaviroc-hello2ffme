use strict;
use warnings;

use Test::More;
use File::Temp 'tempfile';

use FindBin '$RealBin';
use lib "$RealBin/../lib";

use_ok 'Chaviroc::Hello2Ffme', 'data', 'conf', 'value', 'action', 'type',
       'assurance', 'ski', 'slackline', 'trail', 'vtt', 'code_pays', 'conf_pays',
       'telephone';

my $data = data([ 0, 1, 2, 3 ], ['a', 'b', 'c']);
is $data->{a}, 0;
is $data->{b}, 1;
is $data->{c}, 2;
is $data->{d}, undef;

my $conf = mk_conf();
ok -s $conf;

my @fields = conf($conf);
is scalar @fields, 38;

$data = { bonjour => 'aurevoir', salut => 'bisous'};
is value($data, ['field1', 'salut']), 'bisous';
is value($data, ['field2', 'bonjour']), 'aurevoir';

# on considère comme constante si le champ n'existe pas
is value($data, ['field4', 'unknown']), 'unknown';

# permettre champ vide
is value($data, ['field4', '']), '';

is action(0), 'C';
is action(''), 'C';
is action(undef), 'C';
is action('abc'), 'R';

is value($data, ['field5', 'fct:action', 'salut', 'bonjour']), 'R';

# erreur si fct n'existe pas
eval { value($data, ['field5', 'fct:actionNonDefinie', 'salut', 'bonjour']) };
is $@, "ligne: [field5;fct:actionNonDefinie;salut;bonjour]\n[actionNonDefinie] n'est pas une fonction de Chaviroc::Hello2Ffme\n";

is type('Inscription Adulte NON CHAVILLOIS  - Assurance Base +'), 'A';
is type('Inscription Jeune NON CHAVILLOIS - Assurance Base'), 'J';
is type('Inscription Adulte Chavillois - Assurance Base'), 'A';

is assurance('Inscription Adulte NON CHAVILLOIS  - Assurance Base +'), 'B+';
is assurance('Inscription Jeune NON CHAVILLOIS - Assurance Base'), 'B';
is assurance('Inscription Adulte Chavillois - Assurance Base'), 'B';

is telephone('1234'), '0000001234';
is telephone('abc'),  '0000000000';
# conf_pays
my $pays = pays_file();
ok -s $pays;

conf_pays($pays);
is code_pays(''), 'FR';
is code_pays('FRANCE'), 'FR';
is code_pays('BARBADE'), 'BB';
is code_pays('Belgique'), 'BE';

# test compet
my ($fh, $out) = tempfile;
close $fh;
ok -f $out;

my $in = in();
ok -s $in;

my $bin = "$RealBin/../bin/hello2ffme";
ok -x $bin;

my $cmd = "$bin --conf $conf < $in > $out";
ok system($cmd) == 0;
ok -s $out;

my @lines = slurp($out);
is scalar @lines, 5;

done_testing;

sub mk_conf {
    my ($fh, $file) = tempfile;
    print {$fh} qq{champ ffme;champ helloasso ou "fct:nom_fonction" pour appeler une fonction;champ helloasso...
ACTION;fct:action;Champ additionnel: Si vous avez déjà été licencié à la FFME, veuillez renseigner votre n° de licence composé de 6 chiffres (xxxxxx)
NOM;Nom
PRENOM;Prénom
DATE DE NAISSANCE;Date de naissance
SEXE;Champ additionnel: Sexe
NATIONALITE;Champ additionnel: Nationalité
ADRESSE;Champ additionnel: Adresse
ADRESSE COMPLEMENT;Champ additionnel: Complément d'adresse
CODE POSTAL;Champ additionnel: Code Postal
VILLE;Champ additionnel: Ville
PAYS;Champ additionnel: Pays
TEL FIXE;Champ additionnel: Numéro de téléphone fixe
TEL MOBILE;Champ additionnel: Numéro de téléphone mobile
COURRIEL;Champ additionnel: Email
COURRIEL 2;Champ additionnel: Email n°2
GROUPE;
PAP NOM;Champ additionnel: Personne(s) à prévenir en cas d'accident : nom
PAP PRENOM;Champ additionnel: Personne(s) à prévenir en cas d'accident : prénom
PAP ADRESSE;
PAP ADRESSE COMPLEMENT;
PAP CODE POSTAL;
PAP VILLE;
PAP TELEPHONE;Champ additionnel: Personne(s) à prévenir en cas d'accident : téléphone
PAP COURRIEL;Champ additionnel: Personne(s) à prévenir en cas d'accident : email
NUMERO DE LICENCE;Champ additionnel: Si vous avez déjà été licencié à la FFME, veuillez renseigner votre n° de licence composé de 6 chiffres (xxxxxx)
TYPE LICENCE;fct:type;Formule
ASSURANCE;fct:assurance;Formule
OPTION SKI;fct:ski;Formule
OPTION SLACKLINE;fct:slackline;Formule
OPTION TRAIL;fct:trail;Formule
OPTION VTT;fct:vtt;Formule
ASSURANCE COMPLEMENTAIRE;
ATTESTATION SANTE;Champ additionnel: Certificat Médical ou Attestation de Santé (CERFA N°15699*01)
CM TYPE;Champ additionnel: Type de certificat médical
CM MEDECIN;Champ additionnel: Nom du medecin ayant délivré le Certificat Médical
DATE FIN CM PSS;
CM ALPINISME;
CM ALPINISME MEDECIN;
};
    close $fh;

    return $file;
}

sub in {
    my ($fh, $file) = tempfile;

    print {$fh} q{Numéro;Formule;Montant adhésion;Code promo;Statut;Moyen de paiement;Nom;Prénom;Société;Date;Email;Date de naissance;Attestation;Reçu;Numéro de reçu;Carte d'adhérent;Nom acheteur;Prénom acheteur;Adresse acheteur;Code Postal acheteur;Ville acheteur;Pays acheteur;Champ additionnel: Si vous avez déjà été licencié à la FFME, veuillez renseigner votre n° de licence composé de 6 chiffres (xxxxxx);Champ additionnel: Date de naissance;Champ additionnel: Sexe;Champ additionnel: Adresse;Champ additionnel: Complément d'adresse;Champ additionnel: Code Postal;Champ additionnel: Ville;Champ additionnel: Pays;Champ additionnel: Nationalité;Champ additionnel: Numéro de téléphone fixe;Champ additionnel: Numéro de téléphone mobile;Champ additionnel: Email;Champ additionnel: Email n°2;Champ additionnel: Certificat Médical ou Attestation de Santé (CERFA N°15699*01);Champ additionnel: Nom du medecin ayant délivré le Certificat Médical;Champ additionnel: Type de certificat médical;Champ additionnel: Personne(s) à prévenir en cas d'accident : nom;Champ additionnel: Personne(s) à prévenir en cas d'accident : prénom;Champ additionnel: Personne(s) à prévenir en cas d'accident : téléphone;Champ additionnel: Personne(s) à prévenir en cas d'accident : email;Champ additionnel: Photo d'identité pour trombi et/ou licence FFME
37;Inscription Adulte NON CHAVILLOIS  - Assurance Base +;223,00;;Validé;Carte bancaire;Bornier;Pierrick;;01/10/2019 20:36:00;pierrick.bornier@gmail.com;07/10/1994;https://www.helloasso.com/associations/chaviroc/adhesions/adhesion-saison-2020-2/paiement-attestation/10422436;;;https://www.helloasso.com/associations/chaviroc/adhesions/adhesion-saison-2020-2/carte-adherent?id=10422436;BORNIER;Pierrick;;;;FRA;;07/10/1994;H;24 Avenue de la Libération;;92350;Le Plessis-Robinson; France; France;;0675776966;pierrick.bornier@gmail.com;;https://www.helloasso.com/documents/documents_users_souscriptions/certificat medical escalade 19092019-f7d743be77a143eb8e4ce9a46fd0a59e.pdf;VINCENT;Compétition;Bornier;Jean-Philippe;0670918009;jeanphilippe.bornier@gmail.com;https://www.helloasso.com/documents/documents_users_souscriptions/capture-9d32fe5c4e284d8c93036f4ca659a898.png
36;Inscription Jeune NON CHAVILLOIS - Assurance Base;195,00;;Validé;Carte bancaire;Dollé;Thomas;;30/09/2019 18:56:00;vdolle@neuf.fr;17/01/1974;https://www.helloasso.com/associations/chaviroc/adhesions/adhesionn-saison-2020-2/paiement-attestation/10391725;;;https://www.helloasso.com/associations/chaviroc/adhesions/adhesion-saison-2020-2/carte-adherent?id=10391725;GRENETTE;Bénédicte;;;;FRA;;04/10/2002;H;7 rue du Pdt Doumer;;78220;Viroflay; France; France;0175454660;0687546962;vdolle@neuf.fr;;https://www.helloasso.com/documents/documents_users_souscriptions/certificat medical t alpinisme-ce433ff5f5344d5e83283cf71cec2548.jpg;Defaix;Loisir/Alpinisme;Grenette;Bénédicte;0782155681;vdolle@neuf.fr;https://www.helloasso.com/documents/documents_users_souscriptions/photot-e989ed789f184469a00d145188a0bfd3.png
35;Inscription Adulte Chavillois - Assurance Base;205,00;;Validé;Carte bancaire;Falculete;MAtthieu;;30/09/2019 16:20:00;Matthieu.falculete@eicar.fr;24/07/1995;https://www.helloasso.com/associations/chaviroc/adhesions/adhesion-saison-2020-2/paiement-attestation/10387546;;;https://www.helloasso.com/associations/chaviroc/adhesions/adhesion-saison-2020-2/carte-adherent?id=10387546;Falculete;Matthieu;;;;FRA;;24/07/1995;H;11 avenue sainte marie ;chaville;92370;Chaville; France; France;;0619762793;Matthieu.falculete@eicar.fr;;https://www.helloasso.com/documents/documents_users_souscriptions/image 2 -028b5cffe9be4e92a603235a114df594.jpg;Christine Passerieux;Loisir;Etienne;Falculete;0603677923;Etienne.falculete@gmail.com;https://www.helloasso.com/documents/documents_users_souscriptions/image cv-92228da747f74190abea0536aa4e165c.jpg
34;Inscription Adulte Chavillois - Assurance Base;205,00;;Validé;Carte bancaire;Vanderschaeghe;Xavier;;24/09/2019 16:32:00;xvanders@yahoo.com;03/04/1969;https://www.helloasso.com/associations/chaviroc/adhesions/adhesion-saison-2020-2/paiement-attestation/10257661;;;https://www.helloasso.com/associations/chaviroc/adhesions/adhesion-saison-2020-2/carte-adherent?id=10257661;Vanderschaeghe;Xavier;;;;FRA;;03/04/1969;H;5 avenue Berthelot;;92370;Chaville; France; France;;0699078368;xvanders@yahoo.com;;https://www.helloasso.com/documents/documents_users_souscriptions/certif medical escalade-f5a3dc473fa94b2292d7bc2b97fb51f7.jpeg;Dr Imbert;Loisir;Vanderschaeghe;Jasmine;0783434381;jasvan92@yahoo.com;https://www.helloasso.com/documents/documents_users_souscriptions/selfie bievres 2018-915e47d03cb743b480579e40212f8fad.jpg
};
    
    close $fh;
    return $file;
}

sub slurp {
    my $file = shift;

    open my $in, '<', $file
        or die "pb open < $file: $!";

    my @lines;
    
    while (<$in>) {
        push @lines, $_;
    }

    return @lines;
}

sub pays_file {
    my ($fh, $file) = tempfile;
    
    print {$fh} q{PAYS;CODE PAYS
Afghanistan;AF
Afrique du Sud;ZA
Albanie;AL
Algérie;DZ
Allemagne;DE
Andorre;AD
Angola;AO
Anguilla;AI
Antarctique;AQ
Antigua-et-Barbuda;AG
Antilles néerlandaises;AN
Arabie saoudite;SA
Argentine;AR
Arménie;AM
Aruba;AW
Australie;AU
Autriche;AT
Azerbaïdjan;AZ
Bahamas;BS
Bahreïn;BH
Bangladesh;BD
Barbade;BB
Belau;PW
Belgique;BE
Belize;BZ
Bénin;BJ
Bermudes;BM
Bhoutan;BT
Biélorussie;BY
Birmanie;MM
Bolivie;BO
Bosnie-Herzégovine;BA
Botswana;BW
Brésil;BR
Brunei;BN
Bulgarie;BG
Burkina Faso;BF
Burundi;BI
Cambodge;KH
Cameroun;CM
Canada;CA
Cap-Vert;CV
Chili;CL
Chine;CN
Chypre;CY
Colombie;CO
Comores;KM
Congo;CG
Corée du Nord;KP
Corée du Sud;KR
Costa Rica;CR
Côte d'Ivoire;CI
Croatie;HR
Cuba;CU
Danemark;DK
Djibouti;DJ
Dominique;DM
Égypte;EG
Émirats arabes unis;AE
Équateur;EC
Érythrée;ER
Espagne;ES
Estonie;EE
États-Unis;US
Éthiopie;ET
ex-République yougoslave de Macédoine;MK
Finlande;FI
France;FR
Gabon;GA
Gambie;GM
Géorgie;GE
Ghana;GH
Gibraltar;GI
Grèce;GR
Grenade;GD
Groenland;GL
Guadeloupe;GP
Guam;GU
Guatemala;GT
Guinée;GN
Guinée équatoriale;GQ
Guinée-Bissao;GW
Guyana;GY
Guyane française;GF
Haïti;HT
Honduras;HN
Hong Kong;HK
Hongrie;HU
Ile Bouvet;BV
Ile Christmas;CX
Ile Norfolk;NF
Iles Cayman;KY
Iles Cook;CK
Iles des Cocos (Keeling);CC
Iles Falkland;FK
Iles Féroé;FO
Iles Fidji;FJ
Iles Géorgie du Sud et Sandwich du Sud;GS
Iles Heard et McDonald;HM
Iles Marshall;MH
Iles mineures éloignées des États-Unis;UM
Iles Pitcairn;PN
Iles Salomon;SB
Iles Svalbard et Jan Mayen;SJ
Iles Turks-et-Caicos;TC
Iles Vierges américaines;VI
Iles Vierges britanniques;VG
Inde;IN
Indonésie;ID
Iran;IR
Iraq;IQ
Irlande;IE
Islande;IS
Israël;IL
Italie;IT
Jamaïque;JM
Japon;JP
Jordanie;JO
Kazakhstan;KZ
Kenya;KE
Kirghizistan;KG
Kiribati;KI
Koweït;KW
Laos;LA
Lesotho;LS
Lettonie;LV
Liban;LB
Liberia;LR
Libye;LY
Liechtenstein;LI
Lituanie;LT
Luxembourg;LU
Macao;MO
Macédoine;MK
Madagascar;MG
Malaisie;MY
Malawi;MW
Maldives;MV
Mali;ML
Malte;MT
Mariannes du Nord;MP
Maroc;MA
Martinique;MQ
Maurice;MU
Mauritanie;MR
Mayotte;YT
Mexique;MX
Micronésie;FM
Moldavie;MD
Monaco;MC
Mongolie;MN
Montserrat;MS
Mozambique;MZ
Namibie;NA
Nauru;NR
Népal;NP
Nicaragua;NI
Niger;NE
Nigeria;NG
Nioué;NU
Norvège;NO
Nouvelle-Calédonie;NC
Nouvelle-Zélande;NZ
Oman;OM
Ouganda;UG
Ouzbékistan;UZ
Pakistan;PK
Panama;PA
Papouasie-Nouvelle-Guinée;PG
Paraguay;PY
Pays-Bas;NL
Pérou;PE
Philippines;PH
Pologne;PL
Polynésie française;PF
Porto Rico;PR
Portugal;PT
Qatar;QA
République centrafricaine;CF
République démocratique du Congo;CD
République dominicaine;DO
République tchèque;CZ
Réunion;RE
Roumanie;RO
Royaume-Uni;GB
Russie;RU
Rwanda;RW
Sahara occidental;EH
Saint-Christophe-et-Niévès;KN
Saint-Marin;SM
Saint-Pierre-et-Miquelon;PM
Saint-Siège;VA
Saint-Vincent-et-les-Grenadines;VC
Sainte-Hélène;SH
Sainte-Lucie;LC
Salvador;SV
Samoa;WS
Samoa américaines;AS
Sao Tomé-et-Principe;ST
Sénégal;SN
Serbie;SER
Seychelles;SC
Sierra Leone;SL
Singapour;SG
Slovaquie;SK
Slovénie;SI
Somalie;SO
Soudan;SD
Sri Lanka;LK
Suède;SE
Suisse;CH
Suriname;SR
Swaziland;SZ
Syrie;SY
Tadjikistan;TJ
Taïwan;TW
Tanzanie;TZ
Tchad;TD
Terres australes françaises;TF
Territoire britannique de l'Océan Indien;IO
Thaïlande;TH
Timor Oriental;TL
Togo;TG
Tokélaou;TK
Tonga;TO
Trinité-et-Tobago;TT
Tunisie;TN
Turkménistan;TM
Turquie;TR
Tuvalu;TV
Ukraine;UA
Uruguay;UY
Vanuatu;VU
Venezuela;VE
Viêt Nam;VN
Wallis-et-Futuna;WF
Yémen;YE
Zambie;ZM
Zimbabwe;ZW
};
    
    close $fh;
    
    return $file;
}
