package com.capstone.quicklendar.repository.user;

import com.capstone.quicklendar.domain.user.OAuthToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface OAuthUserRepository extends JpaRepository<OAuthToken, Long> {
    Optional<OAuthToken> findByProviderAndProviderId(String provider, String providerId);
}