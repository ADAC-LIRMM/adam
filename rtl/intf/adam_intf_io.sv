/*
 * Copyright 2025 LIRMM
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

interface ADAM_IO;

    logic i;
    logic o;
    logic mode;
    logic otype;

    modport Master (
        input  i,
        output o,
        output mode,
        output otype
    );

    modport Slave (
        output i,
        input  o,
        input  mode,
        input  otype
    );

endinterface