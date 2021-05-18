require "./spec_helper"

describe Material do
  king, queen, rook, bishop, knight, pawn = Piece::Type.values

  it "knows the values of the pieces" do
    new_game do
      material_value.values.should eq [39, 39]
    end
  end

  it "can calculate the value of arbitrary material" do
    new_game do
      material_value({king => 1, queen => 2, rook => 1, pawn => 3}).should eq 26
    end
  end

  it "can determine the material advantage and imbalance" do
    subject Game.from_diagram <<-EOD do
      w - - 0 1
      8 . . . Q . . . .
      7 . Q . . . . Q .
      6 . . . . Q . . .
      5 . . Q . . . . R
      4 Q . . . . Q . .
      3 . . . Q . . . .
      2 . Q . . . . R p
      1 . K . B B N N k
        a b c d e f g h
      EOD
      material_advantage(Side::White).should eq 102
      material_imbalance[Side::Black].should eq({pawn => 1})
    end
  end
end
