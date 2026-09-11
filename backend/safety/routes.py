"""Safety route definitions for Semantic Router.

Each Route contains example utterances in English, Hindi, Marathi,
and Romanized Hindi/Marathi to catch multilingual emergency queries.
"""

try:
    from semantic_router import Route

    emergency = Route(
        name="emergency",
        utterances=[
            # English emergency phrases
            "I am having a heart attack",
            "I can't breathe",
            "someone is unconscious",
            "chest pain radiating to arm",
            "severe allergic reaction",
            "I think I'm having a stroke",
            "profuse bleeding won't stop",
            "I am choking",
            "someone collapsed",
            "severe head injury",
            # Hindi
            "मुझे सांस नहीं आ रही",
            "सीने में दर्द हो रहा है",
            "कोई बेहोश हो गया है",
            "बहुत खून बह रहा है",
            # Marathi
            "मला छातीत दुखतंय",
            "मला श्वास घेता येत नाही",
            # Romanized Hindi (common in Indian chat)
            "heart attack ho raha hai",
            "ambulance bulao",
            "seene mein bahut dard",
            "sans nahi aa rahi",
        ]
    )

    prescription = Route(
        name="prescription",
        utterances=[
            # English
            "prescribe me medicine",
            "which drug should I take",
            "give me medication for diabetes",
            "what medicine should I take for headache",
            "write me a prescription",
            "what dosage should I take",
            # Hindi
            "कौनसी दवाई लेनी चाहिए",
            "मुझे दवाई लिख दो",
            # Marathi
            "कोणती गोळी घ्यावी",
            "मला औषध सांगा",
            # Romanized
            "dawai batao",
            "tablet konsi leni hai",
            "medicine likh do",
        ]
    )

    non_medical = Route(
        name="non_medical",
        utterances=[
            "tell me a joke",
            "what's the weather",
            "who is the prime minister",
            "help me with my homework",
            "write me an essay",
            "play a game with me",
            "what's the stock price",
            "मुझे एक कहानी सुनाओ",
            "cricket ka score kya hai",
        ]
    )

    ROUTES_AVAILABLE = True

except ImportError:
    # semantic-router not installed — routes will use keyword fallback in router.py
    emergency = None
    prescription = None
    non_medical = None
    ROUTES_AVAILABLE = False
