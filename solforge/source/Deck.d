module solforge.Deck;

import solforge.Card;

struct Deck
{
public:


	Deck add(Card card)
	{
		// Check deck length
		if (m_numCards >= 30)
		{
			throw new Exception("Deck is full. No more cards can be added");
		}

		// Check max number of cards
		if (card in m_cardCounts && m_cardCounts[card] >= 3)
		{
			throw new Exception("Cannot have more than 3 copies of a card");
		}

		// Check number of factions
		if (m_factionCounts.length >= 2 && card.faction !in m_factionCounts)
		{
			throw new Exception("Cannot have more than 2 factions");
		}

		// Add the card
		m_cards[m_numCards++] = card;
		m_cardCounts[card]++;
		m_factionCounts[card.faction]++;
			
		return this;
	}

protected:
	// Deck is made up of 30 cards
	Card[] m_cards = new Card[30];

	int[Card] m_cardCounts;
	int[Faction] m_factionCounts;

	int m_numCards = 0;
}


unittest // Add
{
	import std.exception; // assertThrown
	import std.stdio;

	auto ggp = new Card("Grimgaunt Predator", "GGP", Faction.Nekrium, Rarity.Heroic);
	auto wwp = new Card("Weirwood Patriarch", "WWP", Faction.Uterra, Rarity.Heroic);
	auto wmaid = new Card("Wildfire Maiden", "WMaid", Faction.Tempys, Rarity.Heroic);
	auto highlander = new Card("Alloyin Highlander", "AHigh", Faction.Alloyin, Rarity.Heroic);

	Deck NekUt;
	NekUt.add(ggp);
	NekUt.add(wwp);

	// Shouldn't be able to add more than 2 factions
	assertThrown(NekUt.add(wmaid));
	assertThrown(NekUt.add(highlander));

	NekUt.add(ggp);
	NekUt.add(ggp);

	//Shouldn't be able to add more than 3 of a card
	assertThrown(NekUt.add(ggp));
	
	NekUt.add(wwp);
	NekUt.add(wwp);

	assertThrown(NekUt.add(wwp));
}


unittest
{
	
}
