

$in = shift;
$in_ipd = shift;

open(IN1, "$in_ipd");
while(<IN1>){
	chomp $_;
	if (/^>(.+)/){
		$id = $1;
		$ipd{$id} = 1;
	}
}

open(IN, "$in");
$count = 0;
while(<IN>){
	chomp $_;
	$count++;
	@words = split("\t", $_);
	if ($count eq 1){
		for ($i = 1; $i < scalar(@words); $i++){
			if ($words[$i] ne ""){
				$genes[$i] = $words[$i];
				$all{$words[$i]} = 0;
			}
			# print "$i\t$words[$i]\n";
		}
	}
	else{
		# print "$count\t".scalar(@words)."\n";
		for ($i = $count; $i < scalar(@words); $i++){
			if ($words[$i] ne ""){
				$gene = $words[0];
				$$gene{$genes[$i]} = $words[$i];
				# print "$gene\t$genes[$i]\t$$gene{$genes[$i]}\n";
				$gene = $genes[$i];
				$$gene{$words[0]} = $words[$i];
				# print "$gene\t$genes[$i]\t$words[$i]\n"
			}
		}
	}
}

open(IN, "$in");
$count = 0;
while(<IN>){
	chomp $_;
	$count++;
	@words = split("\t", $_);
	if ($count > 1){
		for ($i = 1; $i < $count; $i++){
			if ($words[$i] ne ""){
				$gene = $words[0];
				$$gene{$genes[$i]} = $words[$i] - $$gene{$genes[$i]};
			
				$gene = $genes[$i];
				$$gene{$words[0]} = $words[$i] - $$gene{$words[0]};
			}
		}
	}
}

foreach $gene (keys %all){
	$min{$gene} = 1000;
	$min_gene{$gene} = "";
	$min_ipd{$gene} = 1000;
	$min_gene_ipd{$gene} = "";
	$min_old{$gene} = 1000;
	$min_gene_old{$gene} = "";
	foreach $dis (keys %$gene){
		if ($$gene{$dis} < $min{$gene}){
			# print "$gene\t$dis\t$$gene{$dis}\n";
			$min{$gene} = $$gene{$dis};
			$min_gene{$gene} = $dis;
		}
		elsif ($$gene{$dis} eq $min{$gene}){
			$min_gene{$gene} = "$min_gene{$gene}|$dis";
		}
		if (exists $ipd{$dis}){
			if ($$gene{$dis} < $min_ipd{$gene}){
				$min_ipd{$gene} = $$gene{$dis};
				$min_gene_ipd{$gene} = $dis;
			}
			elsif ($$gene{$dis} eq $min_ipd{$gene}){
				$min_gene_ipd{$gene} = "$min_gene_ipd{$gene}|$dis";
			}
		}
		if ($dis !~ /new/){
			if ($$gene{$dis} < $min_old{$gene}){
				$min_old{$gene} = $$gene{$dis};
				$min_gene_old{$gene} = $dis;
			}
			elsif ($$gene{$dis} eq $min_old{$gene}){
				$min_gene_old{$gene} = "$min_gene_old{$gene}|$dis";
			}
		}
		if ($$gene{$dis} <= 4){
			$all_gene{$gene} = $all_gene{$gene}."$dis:$$gene{$dis},";
		}
	}
}

foreach $gene (keys %all){
	if (exists $ipd{$gene}){
		$status = "IPD";
	}
	else{
		$status = "Novel";
	}
	chop $all_gene{$gene};
	print "$gene\t$status\t$min_gene{$gene}\t$min{$gene}\t$min_gene_old{$gene}\t$min_old{$gene}\t$min_gene_ipd{$gene}\t$min_ipd{$gene}\t$all_gene{$gene}\n";
}