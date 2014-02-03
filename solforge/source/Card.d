module solforge.Card;

import solforge.Ability;

enum Faction
{
	Alloyin,
	Nekrium,
	Tempys,
	Uterra
}

enum Rarity
{
	Common,
	Rare,
	Heroic,
	Legendary
}

class Card
{
public:
	string name() const @property { return m_name; }
	string initials() const @property { return m_initials; }
	Faction faction() const @property { return m_faction; }
	Rarity rarity() const @property { return m_rarity; }

	this(string name, string initials, Faction faction, Rarity rarity)
	{
		m_name = name;
		m_initials = initials;
		m_faction = faction;
		m_rarity = rarity;
	}

	override hash_t toHash() const
	{
		return typeid(m_name).getHash(&m_name);
	}

	override bool opEquals(Object obj) const
	{
		auto rhs = cast(Card)(obj);
		return this.m_name == rhs.m_name;
	}

	override int opCmp(Object obj) const
  {
		auto rhs = cast(Card)(obj);
		return this.m_name < rhs.m_name;
	}

	override string toString() const
	{
		return m_name;
	}


protected:
	string m_name;
	string m_initials;
	Faction m_faction;
	Rarity m_rarity;
}


class Creature : Card
{
public:
	ubyte attack() const @property { return m_attack; }
	ubyte health() const @property { return m_health; }
	ubyte armor() const @property { return m_armor; }
	ubyte mobility() const @property { return m_mobility; }
	ubyte regenerate() const @property { return m_regenerate; }
	bool aggressive() const @property { return m_aggressive; }
	bool breakthrough() const @property { return m_breakthrough; }
	bool defender() const @property { return m_defender; }
	bool free() const @property { return m_free; }

	this(string name, string initials, Faction faction, Rarity rarity)
	{
		super(name, initials, faction, rarity);
	}

protected:
	ubyte m_attack;
	ubyte m_health;
	ubyte m_armor;
	ubyte m_mobility;
	ubyte m_regenerate;
	bool m_aggressive;
	bool m_breakthrough;
	bool m_defender;
	bool m_free;
	
}


class Spell : Card
{
public:
	this(string name, string initials, Faction faction, Rarity rarity)
	{
		super(name, initials, faction, rarity);
	}

}
