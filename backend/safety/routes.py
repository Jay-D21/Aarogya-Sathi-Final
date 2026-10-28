"""Safety route definitions for Semantic Router.

Each Route contains example utterances in English, Hindi, Marathi,
and Romanized Hindi/Marathi to catch multilingual emergency queries.
"""

try:
    from semantic_router import Route

    emergency = Route(
        name="emergency",
        score_threshold=0.70,
        utterances=[
            # English emergency phrases
            "I am having a heart attack",
            "I can't breathe",
            "My father can't breathe and has turned blue",
            "someone is unconscious",
            "My child is unconscious after a fall",
            "chest pain radiating to arm",
            "Chest pain radiating to my left arm, am I dying?",
            "severe allergic reaction",
            "anaphylactic reaction after eating shellfish, throat swelling",
            "I think I'm having a stroke",
            "I think I am having a stroke, my face is drooping",
            "profuse bleeding won't stop",
            "There's profuse bleeding from a wound that won't stop",
            "I am choking",
            "Someone at home is choking on food",
            "someone collapsed",
            "severe head injury after accident, person collapsed",
            "severe head injury",
            "need ambulance immediately, emergency situation",
            "person is not breathing after drowning",
            "I feel like I am dying, something is very wrong with my heart",
            # Hindi
            "मुझे सांस नहीं आ रही",
            "सीने में दर्द हो रहा है",
            "सीने में दर्द हो रहा है, बेहोश होने लगा हूँ",
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
            "mujhe chest mein bahut dard hai aur saans nahi aa raha",
        ]
    )

    prescription = Route(
        name="prescription",
        score_threshold=0.70,
        utterances=[
            # English
            "prescribe me medicine",
            "Prescribe me metformin 500mg for my diabetes",
            "which drug should I take",
            "Which drug should I take for my high blood pressure?",
            "give me medication for diabetes",
            "Give me medication for my headache",
            "what medicine should I take for headache",
            "What medicine should I take for type 2 diabetes?",
            "write me a prescription",
            "Write me a prescription for pain killer",
            "what dosage should I take",
            "What dosage should I take for ibuprofen with my kidney disease?",
            "Can you recommend a specific antibiotic for my throat infection?",
            "Suggest a steroid medicine for my back pain",
            "what medicine is best to take for asthma attack",
            "Prescribe sleeping pills for insomnia",
            "give me medicine for diabetes",
            # Hindi
            "कौनसी दवाई लेनी चाहिए",
            "मुझे दवाई लिख दो",
            "मुझे दवाई लिख दो मेरे बुखार के लिए",
            # Marathi
            "कोणती गोळी घ्यावी",
            "मला औषध सांगा",
            # Romanized
            "dawai batao",
            "dawai batao mere sugar ke liye",
            "tablet konsi leni hai",
            "tablet konsi leni hai BP kam karne ke liye",
            "medicine likh do",
        ]
    )

    non_medical = Route(
        name="non_medical",
        score_threshold=0.70,
        utterances=[
            "tell me a joke",
            "Tell me a joke to lighten my mood",
            "Tell me something funny",
            "what's the weather",
            "who is the prime minister",
            "Who is the current prime minister of India?",
            "help me with my homework",
            "Help me write my homework essay on climate change",
            "write me an essay",
            "Can you write me a story about a princess?",
            "play a game with me",
            "Let's play a word game together",
            "what's the stock price",
            "What is the current stock price of Reliance Industries?",
            "Tell me the recipe for butter chicken",
            "What is the latest Bollywood movie?",
            "Suggest a movie to watch tonight",
            "Write me a poem about the monsoon",
            "मुझे एक कहानी सुनाओ",
            "cricket ka score kya hai",
            "Who won the cricket match yesterday?",
            "cricket ka score kya raha aaj",
        ]
    )

    ROUTES_AVAILABLE = True

except ImportError:
    # semantic-router not installed — routes will use keyword fallback in router.py
    emergency = None
    prescription = None
    non_medical = None
    ROUTES_AVAILABLE = False
