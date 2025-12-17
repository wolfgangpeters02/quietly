package com.quietly.app.ui.screens.auth

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.quietly.app.ui.components.LoadingOverlay
import com.quietly.app.ui.theme.QuietlyColors
import com.quietly.app.ui.theme.QuietlyTextStyles
import com.quietly.app.ui.theme.QuietlyTypography

@Composable
fun AuthScreen(
    onAuthenticated: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(uiState.isAuthenticated) {
        if (uiState.isAuthenticated) {
            onAuthenticated()
        }
    }

    LoadingOverlay(isLoading = uiState.isLoading) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(QuietlyColors.Background)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Spacer(modifier = Modifier.height(60.dp))

                // Logo/Title
                Text(
                    text = "Quietly",
                    style = QuietlyTypography.displaySmall.copy(color = QuietlyColors.Primary),
                    textAlign = TextAlign.Center
                )
                Text(
                    text = "Track your reading journey",
                    style = QuietlyTypography.bodyLarge.copy(color = QuietlyColors.TextSecondary),
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(top = 8.dp)
                )

                Spacer(modifier = Modifier.height(48.dp))

                // Auth Card
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = QuietlyColors.Card),
                    elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp)
                    ) {
                        Text(
                            text = if (uiState.isSignUp) "Create Account" else "Welcome Back",
                            style = QuietlyTypography.headlineSmall,
                            modifier = Modifier.padding(bottom = 24.dp)
                        )

                        // Email field
                        var passwordVisible by remember { mutableStateOf(false) }
                        var confirmPasswordVisible by remember { mutableStateOf(false) }

                        OutlinedTextField(
                            value = uiState.email,
                            onValueChange = viewModel::updateEmail,
                            label = { Text("Email") },
                            leadingIcon = {
                                Icon(Icons.Default.Email, contentDescription = null)
                            },
                            singleLine = true,
                            keyboardOptions = KeyboardOptions(
                                keyboardType = KeyboardType.Email,
                                imeAction = ImeAction.Next
                            ),
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = QuietlyColors.Primary,
                                focusedLabelColor = QuietlyColors.Primary,
                                cursorColor = QuietlyColors.Primary
                            )
                        )

                        Spacer(modifier = Modifier.height(16.dp))

                        // Password field
                        OutlinedTextField(
                            value = uiState.password,
                            onValueChange = viewModel::updatePassword,
                            label = { Text("Password") },
                            leadingIcon = {
                                Icon(Icons.Default.Lock, contentDescription = null)
                            },
                            trailingIcon = {
                                IconButton(onClick = { passwordVisible = !passwordVisible }) {
                                    Icon(
                                        if (passwordVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                                        contentDescription = if (passwordVisible) "Hide password" else "Show password"
                                    )
                                }
                            },
                            singleLine = true,
                            visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                            keyboardOptions = KeyboardOptions(
                                keyboardType = KeyboardType.Password,
                                imeAction = if (uiState.isSignUp) ImeAction.Next else ImeAction.Done
                            ),
                            modifier = Modifier.fillMaxWidth(),
                            colors = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor = QuietlyColors.Primary,
                                focusedLabelColor = QuietlyColors.Primary,
                                cursorColor = QuietlyColors.Primary
                            )
                        )

                        // Confirm password for sign up
                        if (uiState.isSignUp) {
                            Spacer(modifier = Modifier.height(16.dp))

                            OutlinedTextField(
                                value = uiState.confirmPassword,
                                onValueChange = viewModel::updateConfirmPassword,
                                label = { Text("Confirm Password") },
                                leadingIcon = {
                                    Icon(Icons.Default.Lock, contentDescription = null)
                                },
                                trailingIcon = {
                                    IconButton(onClick = { confirmPasswordVisible = !confirmPasswordVisible }) {
                                        Icon(
                                            if (confirmPasswordVisible) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                                            contentDescription = if (confirmPasswordVisible) "Hide password" else "Show password"
                                        )
                                    }
                                },
                                singleLine = true,
                                visualTransformation = if (confirmPasswordVisible) VisualTransformation.None else PasswordVisualTransformation(),
                                keyboardOptions = KeyboardOptions(
                                    keyboardType = KeyboardType.Password,
                                    imeAction = ImeAction.Done
                                ),
                                modifier = Modifier.fillMaxWidth(),
                                colors = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor = QuietlyColors.Primary,
                                    focusedLabelColor = QuietlyColors.Primary,
                                    cursorColor = QuietlyColors.Primary
                                )
                            )
                        }

                        // Error message
                        if (uiState.error != null) {
                            Text(
                                text = uiState.error!!,
                                style = QuietlyTypography.bodySmall.copy(color = QuietlyColors.Error),
                                modifier = Modifier.padding(top = 16.dp)
                            )
                        }

                        Spacer(modifier = Modifier.height(24.dp))

                        // Submit button
                        Button(
                            onClick = { if (uiState.isSignUp) viewModel.signUp() else viewModel.signIn() },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(50.dp),
                            shape = RoundedCornerShape(12.dp),
                            colors = ButtonDefaults.buttonColors(
                                containerColor = QuietlyColors.Primary
                            )
                        ) {
                            Text(
                                text = if (uiState.isSignUp) "Sign Up" else "Sign In",
                                style = QuietlyTextStyles.ButtonText
                            )
                        }

                        Spacer(modifier = Modifier.height(16.dp))

                        // Toggle sign up/sign in
                        Text(
                            text = if (uiState.isSignUp) "Already have an account? Sign In" else "Don't have an account? Sign Up",
                            style = QuietlyTypography.bodyMedium.copy(color = QuietlyColors.Primary),
                            textAlign = TextAlign.Center,
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { viewModel.toggleSignUp() }
                                .padding(8.dp)
                        )
                    }
                }
            }
        }
    }
}
