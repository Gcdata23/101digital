package com.weather.forecast.api.model.request;

import com.weather.forecast.api.model.Coord;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Data
@NoArgsConstructor
@Getter
@Setter
public class City {

    private Long cityId;
}
