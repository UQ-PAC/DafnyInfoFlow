// syncLockLattice.if.dfy

datatype Sec = Public | HR | Marketing | CEO

type Lattice = map<Sec, set<Sec>>

class SyncLock {
  ghost var SyncRead_return_y: int
  ghost var Gamma_SyncRead_return_y: Sec

  function method L_SyncRead_return_y(): Sec
  {
    Marketing
  }

  ghost var Read_return_y: int
  ghost var Gamma_Read_return_y: Sec

  function method L_Read_return_y(): Sec
  {
    CEO
  }

  ghost var SyncWrite_In_secret: int
  ghost var Gamma_SyncWrite_In_secret: Sec

  function method L_SyncWrite_In_secret(): Sec
  {
    CEO
  }

  ghost var Write_In_data: int
  ghost var Gamma_Write_In_data: Sec

  function method L_Write_In_data(): Sec
  {
    Marketing
  }

  function method L_X(Z_in: int := Z): Sec
    reads this
  {
    if Z_in != 1 then
      Marketing
    else
      CEO
  }

  ghost var Gamma_X: Sec
  var X: int

  function method L_Z(): Sec
  {
    Public
  }

  ghost var Gamma_Z: Sec
  var Z: int

  twostate predicate GuaranteeWrite()
    requires Gamma_X in lattice
    requires Gamma_Z in lattice
    reads this
  {
    order(lattice, Gamma_X, L_X()) &&
    order(lattice, Gamma_Z, L_Z())
  }

  method RelyWrite()
    modifies this
    ensures Gamma_X in lattice
    ensures L_X() in lattice
    ensures old(X) == X ==> old(Gamma_X) == Gamma_X
    ensures order(lattice, Gamma_X, L_X())
    ensures Gamma_Z in lattice
    ensures L_Z() in lattice
    ensures old(Z) == Z ==> old(Gamma_Z) == Gamma_Z
    ensures order(lattice, Gamma_Z, L_Z())
    ensures Gamma_Write_In_data in lattice
    ensures L_Write_In_data() in lattice
    ensures old(Write_In_data) == Write_In_data ==> old(Gamma_Write_In_data) == Gamma_Write_In_data
    ensures order(lattice, Gamma_Write_In_data, L_Write_In_data())

  method Write(data: int)
    modifies this
  {
    Gamma_Write_In_data := CEO;
    RelyWrite();
    assert order(lattice, meet[(Gamma_Write_In_data, L_Write_In_data())], L_X());
    label 0:
    X, Gamma_X := data, meet[(Gamma_Write_In_data, L_Write_In_data())];
    assert GuaranteeWrite@0();
  }

  twostate predicate GuaranteeSyncWrite()
    requires Gamma_X in lattice
    requires Gamma_Z in lattice
    reads this
  {
    order(lattice, Gamma_X, L_X()) &&
    order(lattice, Gamma_Z, L_Z())
  }

  method RelySyncWrite()
    modifies this
    ensures Gamma_X in lattice
    ensures L_X() in lattice
    ensures old(X) == X ==> old(Gamma_X) == Gamma_X
    ensures order(lattice, Gamma_X, L_X())
    ensures Gamma_Z in lattice
    ensures L_Z() in lattice
    ensures old(Z) == Z ==> old(Gamma_Z) == Gamma_Z
    ensures order(lattice, Gamma_Z, L_Z())
    ensures Gamma_Write_In_data in lattice
    ensures L_Write_In_data() in lattice
    ensures old(Write_In_data) == Write_In_data ==> old(Gamma_Write_In_data) == Gamma_Write_In_data
    ensures order(lattice, Gamma_Write_In_data, L_Write_In_data())
    ensures Gamma_SyncWrite_In_secret in lattice
    ensures L_SyncWrite_In_secret() in lattice
    ensures old(SyncWrite_In_secret) == SyncWrite_In_secret ==> old(Gamma_SyncWrite_In_secret) == Gamma_SyncWrite_In_secret
    ensures order(lattice, Gamma_SyncWrite_In_secret, L_SyncWrite_In_secret())
    ensures old(Gamma_X) in lattice
    ensures order(lattice, Gamma_X, old(Gamma_X)) && (old(Z) == 1 ==> old(Z) == Z)

  method SyncWrite(secret: int)
    modifies this
    decreases *
  {
    Gamma_SyncWrite_In_secret := CEO;
    RelySyncWrite();
    label 0:
    var b, Gamma_b: Sec;
    assert GuaranteeSyncWrite@0();
    RelySyncWrite();
    label 1:
    b, Z := CAS(Z, 0, 1);
    assert GuaranteeSyncWrite@1();
    Gamma_b, Gamma_Z := Public, if Z == 0 then Public else Gamma_Z;
    RelySyncWrite();
    assert true ==> order(lattice, meet[(Gamma_b, CEO)], secAttack);
    label 4:
    assert b ==> Z == 1;
    while !b
      invariant Gamma_Z in lattice
      invariant Gamma_X in lattice
      invariant b ==> (Z == 1)
      invariant GuaranteeSyncWrite@4()
      decreases *
    {
      RelySyncWrite();
      assert true ==> order(lattice, meet[(Gamma_Z, L_Z())], secAttack);
      label 2:
      while Z != 0
        decreases *
      {
      }
      assert GuaranteeSyncWrite@2();
      RelySyncWrite();
      label 3:
      b, Z := CAS(Z, 0, 1);
      assert GuaranteeSyncWrite@3();
      Gamma_b, Gamma_Z := Public, if Z == 0 then Public else Gamma_Z;
    }
    assert GuaranteeSyncWrite@4();
    RelySyncWrite();
    assert order(lattice, meet[(Gamma_SyncWrite_In_secret, L_SyncWrite_In_secret())], L_X());
    label 5:
    X, Gamma_X := secret, meet[(Gamma_SyncWrite_In_secret, L_SyncWrite_In_secret())];
    assert GuaranteeSyncWrite@5();
    RelySyncWrite();
    assert order(lattice, Public, L_X());
    label 6:
    X, Gamma_X := 0, Public;
    assert GuaranteeSyncWrite@6();
    RelySyncWrite();
    assert order(lattice, Public, L_Z());
    label 7:
    Z, Gamma_Z := 0, Public;
    assert GuaranteeSyncWrite@7();
  }

  twostate predicate GuaranteeRead()
    requires Gamma_X in lattice
    requires Gamma_Z in lattice
    reads this
  {
    order(lattice, Gamma_X, L_X()) &&
    order(lattice, Gamma_Z, L_Z())
  }

  method RelyRead()
    modifies this
    ensures Gamma_X in lattice
    ensures L_X() in lattice
    ensures old(X) == X ==> old(Gamma_X) == Gamma_X
    ensures order(lattice, Gamma_X, L_X())
    ensures Gamma_Z in lattice
    ensures L_Z() in lattice
    ensures old(Z) == Z ==> old(Gamma_Z) == Gamma_Z
    ensures order(lattice, Gamma_Z, L_Z())
    ensures Gamma_Write_In_data in lattice
    ensures L_Write_In_data() in lattice
    ensures old(Write_In_data) == Write_In_data ==> old(Gamma_Write_In_data) == Gamma_Write_In_data
    ensures order(lattice, Gamma_Write_In_data, L_Write_In_data())
    ensures Gamma_SyncWrite_In_secret in lattice
    ensures L_SyncWrite_In_secret() in lattice
    ensures old(SyncWrite_In_secret) == SyncWrite_In_secret ==> old(Gamma_SyncWrite_In_secret) == Gamma_SyncWrite_In_secret
    ensures order(lattice, Gamma_SyncWrite_In_secret, L_SyncWrite_In_secret())
    ensures Gamma_Read_return_y in lattice
    ensures L_Read_return_y() in lattice
    ensures old(Read_return_y) == Read_return_y ==> old(Gamma_Read_return_y) == Gamma_Read_return_y
    ensures order(lattice, Gamma_Read_return_y, L_Read_return_y())

  method Read() returns (y: int)
    modifies this
  {
    Gamma_Read_return_y := CEO;
    RelyRead();
    label 0:
    return X;
    assert GuaranteeRead@0();
  }

  twostate predicate GuaranteeSyncRead()
    requires Gamma_X in lattice
    requires Gamma_Z in lattice
    reads this
  {
    order(lattice, Gamma_X, L_X()) &&
    order(lattice, Gamma_Z, L_Z())
  }

  method RelySyncRead()
    modifies this
    ensures Gamma_X in lattice
    ensures L_X() in lattice
    ensures old(X) == X ==> old(Gamma_X) == Gamma_X
    ensures order(lattice, Gamma_X, L_X())
    ensures Gamma_Z in lattice
    ensures L_Z() in lattice
    ensures old(Z) == Z ==> old(Gamma_Z) == Gamma_Z
    ensures order(lattice, Gamma_Z, L_Z())
    ensures Gamma_Write_In_data in lattice
    ensures L_Write_In_data() in lattice
    ensures old(Write_In_data) == Write_In_data ==> old(Gamma_Write_In_data) == Gamma_Write_In_data
    ensures order(lattice, Gamma_Write_In_data, L_Write_In_data())
    ensures Gamma_SyncWrite_In_secret in lattice
    ensures L_SyncWrite_In_secret() in lattice
    ensures old(SyncWrite_In_secret) == SyncWrite_In_secret ==> old(Gamma_SyncWrite_In_secret) == Gamma_SyncWrite_In_secret
    ensures order(lattice, Gamma_SyncWrite_In_secret, L_SyncWrite_In_secret())
    ensures Gamma_Read_return_y in lattice
    ensures L_Read_return_y() in lattice
    ensures old(Read_return_y) == Read_return_y ==> old(Gamma_Read_return_y) == Gamma_Read_return_y
    ensures order(lattice, Gamma_Read_return_y, L_Read_return_y())
    ensures Gamma_SyncRead_return_y in lattice
    ensures L_SyncRead_return_y() in lattice
    ensures old(SyncRead_return_y) == SyncRead_return_y ==> old(Gamma_SyncRead_return_y) == Gamma_SyncRead_return_y
    ensures order(lattice, Gamma_SyncRead_return_y, L_SyncRead_return_y())
    ensures old(Gamma_X) in lattice
    ensures old(Z) == 2 ==> old(Z) == Z && order(lattice, Gamma_X, old(Gamma_X))

  method SyncRead() returns (y: int)
    modifies this
  {
    Gamma_SyncRead_return_y := CEO;
    RelySyncRead();
    label 0:
    var b, Gamma_b: Sec;
    assert GuaranteeSyncRead@0();
    RelySyncRead();
    label 1:
    b, Z := CAS(Z, 0, 2);
    assert GuaranteeSyncRead@1();
    Gamma_b, Gamma_Z := Public, if Z == 0 then Public else Gamma_Z;
    RelySyncRead();
    assert order(lattice, meet[(Gamma_b, CEO)], secAttack);
    label 5:
    if b {
      RelySyncRead();
      assert order(lattice, meet[(Gamma_X, L_X())], L_SyncRead_return_y());
      label 2:
      y, Gamma_SyncRead_return_y := X, meet[(Gamma_X, L_X())];
      assert GuaranteeSyncRead@2();
      RelySyncRead();
      assert order(lattice, Public, L_Z());
      label 3:
      Z, Gamma_Z := 0, Public;
      assert GuaranteeSyncRead@3();
      RelySyncRead();
      label 4:
      return y;
      assert GuaranteeSyncRead@4();
    }
    assert GuaranteeSyncRead@5();
  }
}

const secAttack: Sec := Marketing // Change as needed
const lattice: Lattice := map[Public := {Public, HR, Marketing, CEO}, HR := {HR, CEO}, Marketing := {Marketing, CEO}, CEO := {CEO}]

method CAS<T(==)>(x: T, e1: T, e2: T)
    returns (b: bool, x2: T)
  ensures x == e1 ==> x2 == e2 && b
  ensures x != e1 ==> x2 == x && !b
{
  if x == e1 {
    x2 := e2;
    b := true;
  } else {
    x2 := x;
    b := false;
  }
}

predicate order(l: Lattice, a: Sec, b: Sec)
  requires a in l
  requires b in l
{
  b in l[a]
}

const join: map<(Sec, Sec), Sec> := map[(Public, Public) := Public, (Public, HR) := HR, (Public, Marketing) := Marketing, (Public, CEO) := CEO, (HR, Public) := HR, (HR, HR) := HR, (HR, Marketing) := CEO, (HR, CEO) := CEO, (Marketing, Public) := Marketing, (Marketing, HR) := CEO, (Marketing, Marketing) := Marketing, (Marketing, CEO) := CEO, (CEO, Public) := CEO, (CEO, HR) := CEO, (CEO, Marketing) := CEO, (CEO, CEO) := CEO]
const meet: map<(Sec, Sec), Sec> := map[(Public, Public) := Public, (Public, HR) := Public, (Public, Marketing) := Public, (Public, CEO) := Public, (HR, Public) := Public, (HR, HR) := HR, (HR, Marketing) := Public, (HR, CEO) := HR, (Marketing, Public) := Public, (Marketing, HR) := Public, (Marketing, Marketing) := Marketing, (Marketing, CEO) := Marketing, (CEO, Public) := Public, (CEO, HR) := HR, (CEO, Marketing) := Marketing, (CEO, CEO) := CEO]
