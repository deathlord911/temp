BEGIN{del=0}
# Start eines Heredocs wie: want=$(cat <<'EOF')  /  want_b=$(cat <<EOF)
=[[:space:]]*\$\([[:space:]]*cat[[:space:]]*<<'?EOF'?[[:space:]]*\)[[:space:]]*$ { del=1; next }
# Ende des Heredocs: eine Zeile mit nur "EOF" (optional eingerückt)
del && /^[[:space:]]*EOF[[:space:]]*$/ { del=0; next }
# Alles innerhalb des Heredocs verwerfen
del { next }
# Rest durchreichen
{ print }
