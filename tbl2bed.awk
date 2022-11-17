#!/opt/homebrew/bin/gawk -E
#Written by Ryan D. Ward
#ryandward [_at_] gmail [_dot_] com
#September 20, 2020

BEGIN{
  FS="\t";
  OFS="\t";
  PROCINFO["sorted_in"] = "@ind_num_asc";
}

($3 || $0~"^>") && n && locus_tag{
  for(i = 1; i <= n; i++){
    print chr,
    left[feature][i],
    right[feature][i],
    locus_tag,
    gene,
    strand[feature][i],
    pseudo""feature,
    complete
  }
  n=0
}

$0~"^>"{
  independent_feature_count = 0;
  f1 = match($0,/\|(.*?)\|/,chr_match);
  if(f1){chr=chr_match[1]; next}
  f2 = match($0,/ (.*?)/,chr_match);
  if(f2){chr=chr_match[1];}

  next;
}

$3 && ($3 != "CDS" && $3 != "tRNA" && $3 != "ncRNA" && $3 != "rRNA" && $3 != "mRNA") {
  independent_feature_count++;
  gene = ".";
  this_file = FILENAME;
  split(this_file, file_parts, ".");
  this_file = file_parts[1];
  locus_tag = chr"__"independent_feature_count;
  gsub("\\.", "v", locus_tag)
  split(locus_tag,locus_tag_parts,"/")
  locus_tag = locus_tag_parts[length(locus_tag_parts)]
  delete(left);
  delete(right);
}

$3 {
  pseudo = "";
  complete = "";
  feature = $3;
}

$1 && $2 {
  n++;

  n1 = gsub(/[^0-9]/, "", $1);
  n2 = gsub(/[^0-9]/, "", $2);

  left[feature][n] = $2 > $1 ? $1-1 : $2-1
  right[feature][n] = $2 > $1 ? $2 : $1
  strand[feature][n] = $2 > $1 ? "+" : "-"

  complete = n1+n2 > 0 ? "partial" : "complete"
}

$4 == "pseudo" {
  pseudo = "pseudo-"
}

$4 == "locus_tag" {
  locus_tag = $5;
}

$4 == "gene" {
  gene = $5
}


 END{
     for(i = 1; i <= n; i++){
       print chr,
         left[feature][i],
         right[feature][i],
         locus_tag,
         gene,
         strand[feature][i],
         pseudo""feature,
         complete     }
     n=0
 }
