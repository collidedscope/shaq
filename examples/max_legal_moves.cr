require "shaq"

# https://www.stmintz.com/ccc/index.php?id=424980
game = Shaq::Game.from_fen "3Q4/1Q4Q1/4Q3/2Q4R/Q4Q2/3Q4/1Q4Rp/1K1BBNNk w - - 0 1"
expected = <<-EOS.split
Ba5 Bb3 Bb4 Bc2 Bc3 Bd2 Be2 Bf2 Bf3 Bg3 Bg4 Bh4 Ka1 Ka2 Kc1 Kc2 Nd2 Ne2 Ne3 Nf3
Ng3# Nh3 Nxh2 Q2b3 Q2b4 Q2b5 Q2b6 Q3d4 Q3d5 Q3d6 Q3d7 Q7b3 Q7b4 Q7b5 Q7b6 Q8d4
Q8d5 Q8d6 Q8d7 Qaa1 Qaa2 Qaa3 Qaa5 Qaa6 Qaa7 Qaa8 Qab3 Qab4 Qab5 Qac2 Qac4 Qac6
Qad4 Qad7 Qae4 Qae8 Qba1 Qba2 Qba3 Qba6 Qba7 Qba8 Qbb8 Qbc1 Qbc2 Qbc3 Qbc6 Qbc7
Qbc8 Qbd2 Qbd4 Qbd5 Qbd7 Qbe2 Qbe4 Qbe5 Qbe7 Qbf2 Qbf3 Qbf6 Qbf7 Qca3 Qca5 Qca7
Qcb4 Qcb5 Qcb6 Qcc1 Qcc2 Qcc3 Qcc4 Qcc6 Qcc7 Qcc8 Qcd4 Qcd5 Qcd6 Qce3 Qce5 Qce7
Qcf2 Qcf5 Qcf8 Qcg5 Qda3 Qda5 Qda6 Qda8 Qdb3 Qdb5 Qdb6 Qdb8 Qdc2 Qdc3 Qdc4 Qdc7
Qdc8 Qdd2 Qde2 Qde3 Qde4 Qde7 Qde8 Qdf3 Qdf5 Qdf6 Qdf8 Qdg3 Qdg5 Qdg6 Qdg8 Qdh3
Qdh4 Qdh7 Qdh8 Qea2 Qea6 Qeb3 Qeb6 Qec4 Qec6 Qec8 Qed5 Qed6 Qed7 Qee2 Qee3 Qee4
Qee5 Qee7 Qee8 Qef5 Qef6 Qef7 Qeg4 Qeg6 Qeg8 Qeh3 Qeh6 Qfb4 Qfb8 Qfc1 Qfc4 Qfc7
Qfd2 Qfd4 Qfd6 Qfe3 Qfe4 Qfe5 Qff2 Qff3 Qff5 Qff6 Qff7 Qff8 Qfg3 Qfg4 Qfg5 Qfh4
Qfh6 Qgc3 Qgc7 Qgd4 Qgd7 Qge5 Qge7 Qgf6 Qgf7 Qgf8 Qgg3 Qgg4 Qgg5 Qgg6 Qgg8 Qgh6
Qgh7 Qgh8 Qxh2# Rc2# Rd2# Rd5 Re2# Re5 Rf2# Rf5 Rg3# Rg4# Rg6# Rgg5# Rgxh2# Rh3
Rh4 Rh6 Rh7 Rh8 Rhg5 Rhxh2#
EOS

moves = game.legal_moves.map { |m| game.algebraic_move *m }.sort!
p moves == expected
