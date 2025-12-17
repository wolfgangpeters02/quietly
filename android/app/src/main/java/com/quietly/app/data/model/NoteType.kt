package com.quietly.app.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
enum class NoteType {
    @SerialName("note")
    NOTE,

    @SerialName("quote")
    QUOTE
}
